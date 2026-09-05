# JUPI

JUPI is a small 3D game where you aim and shoot at a moving target cube. You can play with a mouse, or with your hands in front of a webcam.

## What is JUPI?

JUPI is a first-person game I made to learn game development. There is a red cube that moves around in a room. You need to look at it and shoot it. When you hit it, it jumps to a new place and keeps moving. The game counts your hits and shows your accuracy and time.

The cool part is the hand controls. If you have a webcam, you can hold your hands up and control the camera with a pinch. No controller needed.

## How it works

There are two ways to aim:

1. Mouse — direct and simple.
2. Webcam → MediaPipe → hand landmarks → Godot.

The hand tracking works like this:

- The webcam records your hands.
- MediaPipe finds the hand landmarks (fingers, joints, and so on).
- A small Python program sends this data to Godot over UDP.
- Godot turns the data into camera movement and shots.

The crosshair is always in the middle of the screen. The shot always goes through the center of the screen, so if the crosshair is on the target, you hit it.

## Features

- 3D first-person view with WASD movement
- Center crosshair that never moves
- A red target cube that respawns and drifts after you hit it
- Hit counter with accuracy and time
- Hand tracking with a webcam:
  - left hand pinch = camera look
  - right hand pinch = shoot once
  - open hands = walk forward
- Mouse controls work without a webcam
- Hand tracker starts and closes together with the game

## Tech I used

- Godot 4.7
- GDScript
- Python
- MediaPipe
- OpenCV
- UDP (localhost)
- macOS webcam

## How to run

You need Godot 4.7 and Python 3 (the tracker was tested with 3.12).

1. Install Godot 4.7 from the Godot website.
2. Open the project folder in Godot and run the main scene (F5).
3. The game starts. You can play with the mouse right away.
4. For hand tracking, the Python tracker needs to run. The game starts it by itself when it can.

### Setting up the Python tracker

The tracker uses a virtual environment at `hand_tracking/.venv`. It is not in the repository, so you need to create it once:

```bash
python3 -m venv hand_tracking/.venv
hand_tracking/.venv/bin/pip install opencv-contrib-python mediapipe
```

Then run the game again. The tracker should start by itself and connect to the game on UDP port 37020.

If you are on macOS, the system may ask for camera permission the first time. Allow it.

No webcam or no tracker? No problem. The game still works with the mouse.

## Controls

Mouse:

- WASD — move
- Mouse — look around
- Left click — shoot
- Escape — release the mouse, click to capture it again

Hands (in hand mode):

- Left hand pinch (thumb + index) — control the camera
- Move your left hand while pinching — look around
- Let go — the camera stops
- Right hand pinch — shoot once
- Let go and pinch again — shoot again
- Open hands — walk forward

Press H to switch between mouse and hand controls.

## Project structure

- `project.godot` — the Godot project file
- `scenes/` — the 3D scene files
- `scripts/` — the GDScript game code
- `hand_tracking/` — the Python webcam tracker
- `tests/` — runtime tests for the game

## My goal

I made this project to learn game development, computer vision, and how to connect Python with Godot. JUPI started as a 2D idea, and I turned it into a small 3D game where your hands are the controller. I learned a lot about physics, raycasting, UDP networking, and hand tracking while making it.

## Credits / libraries

- Godot Engine — the game engine
- MediaPipe — hand landmark detection
- OpenCV — webcam capture and the preview window
- NumPy — used by MediaPipe and OpenCV
- Python — the hand tracker

The hand landmark model (`hand_tracking/hand_landmarker.task`) comes from MediaPipe.