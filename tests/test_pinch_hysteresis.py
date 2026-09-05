#!/usr/bin/env python3
"""Unit tests for the pinch hysteresis band in hand_tracking/main.py.

The tracker must never flicker between pinch and open when the fingertip
distance hovers around the boundary:

- an accidental RIGHT-hand flip fires an extra shot (each open -> pinch
  transition is one "right,pinch" edge);
- an accidental LEFT-hand flip re-arms camera look (baseline resets, the
  view can jump).

The hysteresis band between PINCH_ON_THRESHOLD and PINCH_OFF_THRESHOLD
keeps the current state while the distance is inside the band, so jitter
there cannot flip it. These tests pin down that behavior.

Run from the project root:
    hand_tracking/.venv/bin/python -m unittest discover -s tests -p "test_*.py" -v
Exit code 0 = all tests passed.
"""

import os
import sys
import unittest

try:
    from hand_tracking import main as tracker
except ImportError:  # allow running from other cwds
    sys.path.insert(
        0, os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "hand_tracking")
    )
    import main as tracker


class TestPinchHysteresis(unittest.TestCase):
    """Verifies the hysteresis band around PINCH_ON/OFF_THRESHOLD."""

    def test_thresholds_are_sane(self):
        # The band needs a positive width; a single threshold would flicker.
        self.assertLess(tracker.PINCH_ON_THRESHOLD, tracker.PINCH_OFF_THRESHOLD)

    def test_open_hand_stays_open(self):
        # Measured open hands are 0.08+, all above the on-threshold.
        self.assertFalse(tracker.next_pinch_state(False, 0.10))
        self.assertFalse(tracker.next_pinch_state(False, tracker.PINCH_OFF_THRESHOLD + 0.01))
        self.assertFalse(tracker.next_pinch_state(False, 0.20))

    def test_firm_pinch_closes_the_hand(self):
        # Measured deliberate pinches are 0.02-0.06: below the on-threshold.
        self.assertTrue(tracker.next_pinch_state(False, 0.02))
        self.assertTrue(tracker.next_pinch_state(False, 0.05))
        self.assertTrue(tracker.next_pinch_state(False, tracker.PINCH_ON_THRESHOLD - 0.001))

    def test_band_holds_the_pinch_while_hovering(self):
        # While pinched, distances inside the band must NOT release the
        # pinch: jitter at the boundary cannot re-arm camera look / fire.
        for dist in (tracker.PINCH_ON_THRESHOLD + 0.001, 0.07, 0.08, 0.089):
            self.assertTrue(
                tracker.next_pinch_state(True, dist),
                "pinched hand must stay pinched at dist %.3f" % dist,
            )

    def test_band_holds_open_while_hovering(self):
        # While open, distances inside the band must NOT trigger a pinch:
        # hovering fingers just above the on-threshold fire nothing.
        for dist in (tracker.PINCH_ON_THRESHOLD + 0.001, 0.07, 0.08, 0.089):
            self.assertFalse(
                tracker.next_pinch_state(False, dist),
                "open hand must stay open at dist %.3f" % dist,
            )

    def test_open_past_off_threshold_releases(self):
        # A pinched hand whose fingers open past PINCH_OFF_THRESHOLD
        # reports open again (exactly one release edge).
        self.assertFalse(tracker.next_pinch_state(True, tracker.PINCH_OFF_THRESHOLD + 0.001))
        self.assertFalse(tracker.next_pinch_state(True, 0.12))

    def test_oscillation_inside_band_never_flips(self):
        # Fingers oscillating anywhere inside the band must never flip the
        # state: open stays open, pinched stays pinched.
        state = False
        for dist in (0.07, 0.065, 0.08, 0.07, 0.089, 0.061, 0.075):
            state = tracker.next_pinch_state(state, dist)
            self.assertFalse(state, "open hand flipped at dist %.3f" % dist)
        state = True
        for dist in (0.07, 0.089, 0.065, 0.08, 0.07, 0.061, 0.085):
            state = tracker.next_pinch_state(state, dist)
            self.assertTrue(state, "pinched hand flipped at dist %.3f" % dist)

    def test_exact_boundary_values(self):
        # Both comparisons are strict (<): the exact on-threshold keeps an
        # open hand open, and the exact off-threshold releases a pinch.
        self.assertFalse(tracker.next_pinch_state(False, tracker.PINCH_ON_THRESHOLD))
        self.assertFalse(tracker.next_pinch_state(True, tracker.PINCH_OFF_THRESHOLD))
        # An epsilon below each threshold does flip the state.
        self.assertTrue(tracker.next_pinch_state(False, tracker.PINCH_ON_THRESHOLD - 1e-9))
        self.assertTrue(tracker.next_pinch_state(True, tracker.PINCH_OFF_THRESHOLD - 1e-9))

    def test_round_trip_emits_exactly_one_pinch_and_one_release(self):
        # Simulates the tracker's edge detection over a realistic gesture
        # (open -> firm pinch -> hovering -> open again) and verifies the
        # state machine emits exactly one pinch edge and one release edge:
        # the no-double-shot property of the right hand.
        pinched = False
        edges = []
        for dist in (0.10, 0.05, 0.08, 0.07, 0.089, 0.065, 0.12):
            now = tracker.next_pinch_state(pinched, dist)
            if now and not pinched:
                edges.append("pinch")
            elif not now and pinched:
                edges.append("release")
            pinched = now
        self.assertEqual(edges, ["pinch", "release"])
        self.assertFalse(pinched, "hand must end the gesture open")


if __name__ == "__main__":
    unittest.main()