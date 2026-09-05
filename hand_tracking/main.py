#!/usr/bin/env python3
"""Two-hand webcam tracker for JUPI's camera + shooting controls.

MacBook camera -> detect up to two hands -> handedness (MediaPipe) ->
per-hand pinch gestures (thumb tip 4 + index fingertip 8) -> events
sent to Godot over localhost UDP.

Control scheme:
  LEFT hand  = camera look. While the left pinch is held, Godot rotates
               the camera by the RELATIVE movement of the left hand.
               The tracker sends the left hand's position only while the
               left pinch is active; Godot turns position deltas into
               yaw/pitch.
  RIGHT hand = shoot. Each open -> pinch transition of the right hand
               sends exactly one "right,pinch" message (edge-triggered).
               Holding the pinch sends nothing more.
  Movement   = open hands. Godot walks forward while any detected hand
               is OPEN (not pinched). The tracker reports each hand's
               appear/leave and pinch/open edges so Godot always knows
               the current open/pinched state of both hands:
               hand,<side> on appear, <side>,gone on leave,
               <side>,pinch / <side>,release on transitions.

Press Q to quit.
"""

import math
import os
import socket
import time

import cv2
import mediapipe as mp
from mediapipe.tasks.python import BaseOptions
from mediapipe.tasks.python.vision import HandLandmarker, HandLandmarkerOptions, RunningMode

# Thumb tip is landmark 4, index fingertip is landmark 8 in MediaPipe's
# 21-hand-landmark model. The pinch point we track is their midpoint.
THUMB_TIP = 4
INDEX_FINGERTIP = 8

MODEL_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "hand_landmarker.task")

FRAME_WIDTH = 640
FRAME_HEIGHT = 480

# --- Pinch gesture --------------------------------------------------------
# Pinch = index fingertip (8) and thumb tip (4) closer than this
# normalized (Euclidean, x/y/z) distance. Calibrated live: deliberate
# pinches measure 0.02-0.06, open hand 0.08+, so PINCH_ON_THRESHOLD fires
# on a firm pinch and PINCH_OFF_THRESHOLD ignores fingers hovering around
# 0.08. The two thresholds form a hysteresis band: once pinched, fingers
# must open past 0.09 before the hand reports open again (and vice versa),
# so slight jitter around the boundary cannot flip the state and fire
# accidental double-shots or re-arm the camera look repeatedly.
PINCH_ON_THRESHOLD = 0.06
PINCH_OFF_THRESHOLD = 0.09

# --- UDP output to the JUPI Godot receiver -------------------------------
# The Godot hand source binds this same port on 127.0.0.1.
UDP_IP = "127.0.0.1"
UDP_PORT = 37020

# --- Mirroring and handedness --------------------------------------------
# Front-facing webcams capture you the way another person sees you, i.e.
# NOT mirrored. The preview is flipped (MIRROR_X) so it looks like a
# mirror, and all coordinates we send are in that mirrored space, so
# what you see matches what Godot receives.
MIRROR_X = True

# MediaPipe determines handedness ASSUMING the input image is mirrored
# (a selfie view). We feed it the raw, non-mirrored frames, so its
# "Left"/"Right" labels come out swapped relative to your physical
# hands - OR they already match, depending on the camera/OS handling.
# Verified on the real MacBook webcam: raw labels ALREADY match the
# physical hands, so no swap is applied. If a future test shows the
# labels reversed again, flip this flag back to True.
SWAP_HANDEDNESS = False

# Ignore a hand when its handedness classification is this unsure.
HANDEDNESS_MIN_SCORE = 0.5

# Exponential smoothing (0..1) applied to the sent left-hand position so
# camera rotation is stable; higher = smoother/slower response. 0.3 keeps
# the camera from feeling laggy behind quick hand sweeps while still
# filtering frame-to-frame jitter.
POSITION_SMOOTHING = 0.3
# --------------------------------------------------------------------------


def _mirror_x(x: float) -> float:
    return 1.0 - x if MIRROR_X else x


def _pinch_distance(landmarks) -> float:
    """Normalized Euclidean distance between thumb tip (4) and index
    fingertip (8), including depth (z): two fingertips can share the same
    x/y but be far apart along z (e.g. a finger pointing at the camera),
    which is not a pinch. For a real pinch the tips touch, so z adds ~0
    and the calibrated thresholds stay valid."""
    return math.hypot(
        landmarks[INDEX_FINGERTIP].x - landmarks[THUMB_TIP].x,
        landmarks[INDEX_FINGERTIP].y - landmarks[THUMB_TIP].y,
        landmarks[INDEX_FINGERTIP].z - landmarks[THUMB_TIP].z,
    )


def next_pinch_state(pinched: bool, dist: float) -> bool:
    """Applies the hysteresis band to one hand's pinch state.

    A hand becomes pinched when the fingertip distance closes below
    PINCH_ON_THRESHOLD and stays pinched until the fingers open past
    PINCH_OFF_THRESHOLD. Distances inside the band (between the two
    thresholds) keep the current state, so jitter around the boundary
    cannot flip it: an accidental right-hand flip would fire an extra
    shot and an accidental left-hand flip would re-arm camera look.

    Both comparisons are strict (<), so the exact threshold values keep
    the current state (0.06 stays open, 0.09 releases a pinch).
    """
    if pinched:
        return dist < PINCH_OFF_THRESHOLD
    return dist < PINCH_ON_THRESHOLD


def _pinch_point(landmarks):
    """Midpoint of thumb tip and index fingertip (where the pinch is)."""
    return (
        (landmarks[THUMB_TIP].x + landmarks[INDEX_FINGERTIP].x) / 2.0,
        (landmarks[THUMB_TIP].y + landmarks[INDEX_FINGERTIP].y) / 2.0,
    )


def main() -> None:
    options = HandLandmarkerOptions(
        base_options=BaseOptions(model_asset_path=MODEL_PATH),
        running_mode=RunningMode.VIDEO,
        num_hands=2,
        min_hand_detection_confidence=0.5,
        min_tracking_confidence=0.5,
    )

    capture = cv2.VideoCapture(0)
    if not capture.isOpened():
        raise RuntimeError("Could not open the webcam (index 0).")

    capture.set(cv2.CAP_PROP_FRAME_WIDTH, FRAME_WIDTH)
    capture.set(cv2.CAP_PROP_FRAME_HEIGHT, FRAME_HEIGHT)

    udp = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

    def send(text: str) -> None:
        udp.sendto(text.encode("ascii"), (UDP_IP, UDP_PORT))

    print("Hand tracking started (TWO hands). Press Q to quit.")
    print(f"Sending -> UDP {UDP_IP}:{UDP_PORT}  mirror X: {MIRROR_X}  swap handedness: {SWAP_HANDEDNESS}")

    # Per-hand edge state. "Left"/"Right" are the PHYSICAL hand labels
    # after SWAP_HANDEDNESS.
    prev_seen = {"Left": False, "Right": False}
    pinched = {"Left": False, "Right": False}
    left_smooth = None  # smoothed left-hand position while pinched

    with HandLandmarker.create_from_options(options) as landmarker:
        frame_index = 0
        while True:
            ok, frame = capture.read()
            if not ok:
                print("Failed to read a frame from the webcam.")
                break

            frame_index += 1
            mp_image = mp.Image(
                image_format=mp.ImageFormat.SRGB, data=cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            )
            result = landmarker.detect_for_video(mp_image, frame_index)

            # Preview is mirrored to match the sent coordinates.
            preview = cv2.flip(frame, 1) if MIRROR_X else frame

            # Collect this frame's hands keyed by physical label. The
            # handedness list lines up with the landmarks list (one entry
            # per detected hand).
            hands: dict = {}
            if result.hand_landmarks:
                for i, lm in enumerate(result.hand_landmarks):
                    if i >= len(result.handedness):
                        break
                    cat = result.handedness[i][0]
                    if cat.score < HANDEDNESS_MIN_SCORE:
                        continue  # too unsure: treat as not detected
                    label = cat.category_name  # "Left" / "Right"
                    if SWAP_HANDEDNESS:
                        label = "Right" if label == "Left" else "Left"
                    hands[label] = lm

            # --- Presence events (edge-triggered) ---------------------
            # Godot uses the first hand event to switch to hand mode, so
            # a user holding both hands up without pinching still gets
            # hand controls enabled. Appear and leave are reported per
            # hand so Godot always knows which hands are present (an
            # open, present hand makes the player walk).
            for label in ("Left", "Right"):
                side = label.lower()
                seen = label in hands
                if seen and not prev_seen[label]:
                    send(f"hand,{side}")
                    print(f"hand {side} detected")
                elif not seen and prev_seen[label]:
                    send(f"{side},gone")
                    print(f"hand {side} gone")
                prev_seen[label] = seen

            # --- LEFT hand: camera look while pinched ------------------
            left = hands.get("Left")
            if left is not None:
                dist = _pinch_distance(left)
                # Hysteresis band: no flicker around the boundary, see
                # next_pinch_state().
                now_pinched = next_pinch_state(pinched["Left"], dist)
                if now_pinched and not pinched["Left"]:
                    send("left,pinch")
                    print("left,pinch -> UDP  (d=%.3f)" % dist)
                elif not now_pinched and pinched["Left"]:
                    send("left,release")
                    print("left,release -> UDP  (d=%.3f)" % dist)
                pinched["Left"] = now_pinched

                if now_pinched:
                    # Send the left hand position ONLY while pinched.
                    # Godot computes deltas from consecutive packets.
                    px, py = _pinch_point(left)
                    px = _mirror_x(px)
                    if left_smooth is None:
                        left_smooth = (px, py)
                    else:
                        a = POSITION_SMOOTHING
                        left_smooth = (
                            left_smooth[0] + a * (px - left_smooth[0]),
                            left_smooth[1] + a * (py - left_smooth[1]),
                        )
                    send("left,%.3f,%.3f" % left_smooth)
            else:
                # left,gone was already sent in the presence section, so
                # Godot disarmed camera look there; only the local state
                # resets here.
                pinched["Left"] = False
                left_smooth = None

            # --- RIGHT hand: one shot per pinch ------------------------
            right = hands.get("Right")
            if right is not None:
                dist = _pinch_distance(right)
                # Hysteresis (same as the left hand): no flicker means no
                # accidental extra shots from fingers hovering at the
                # boundary - each open -> pinch transition fires once.
                now_pinched = next_pinch_state(pinched["Right"], dist)
                if now_pinched and not pinched["Right"]:
                    # Edge: open -> pinched. Exactly one shot event, then
                    # nothing until the fingers separate again.
                    send("right,pinch")
                    print("right,pinch -> UDP  (d=%.3f)" % dist)
                elif not now_pinched and pinched["Right"]:
                    # Edge: pinched -> open. Godot resumes walking (an
                    # open hand moves the player forward).
                    send("right,release")
                    print("right,release -> UDP  (d=%.3f)" % dist)
                pinched["Right"] = now_pinched
            else:
                # right,gone was already sent in the presence section.
                pinched["Right"] = False

            # --- Preview -------------------------------------------------
            for label in ("Left", "Right"):
                lm = hands.get(label)
                if lm is None:
                    continue
                tip = lm[INDEX_FINGERTIP]
                thumb = lm[THUMB_TIP]
                px = int(_mirror_x(tip.x) * preview.shape[1])
                py = int(tip.y * preview.shape[0])
                color = (0, 255, 0) if label == "Left" else (0, 160, 255)
                cv2.circle(preview, (px, py), 8, color, 2)
                cv2.circle(preview, (px, py), 2, color, -1)
                tx = int(_mirror_x(thumb.x) * preview.shape[1])
                ty = int(thumb.y * preview.shape[0])
                cv2.circle(preview, (tx, ty), 6, color, 2)
                cv2.line(preview, (px, py), (tx, ty), color, 1)
                state = "PINCH" if pinched[label] else "open"
                cv2.putText(
                    preview,
                    f"{label}: {state}",
                    (px - 20, py - 14),
                    cv2.FONT_HERSHEY_SIMPLEX,
                    0.6,
                    color,
                    2,
                )

            if not hands:
                cv2.putText(
                    preview,
                    "No hands detected",
                    (10, 30),
                    cv2.FONT_HERSHEY_SIMPLEX,
                    0.7,
                    (0, 0, 255),
                    2,
                )

            cv2.imshow("JUPI - Two-Hand Tracking", preview)

            if cv2.waitKey(1) & 0xFF == ord("q"):
                break

    udp.close()
    capture.release()
    cv2.destroyAllWindows()
    print("Exited cleanly.")


if __name__ == "__main__":
    main()