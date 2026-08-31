# ARTIST WORKFLOW — JUPI 2D

How to draw a sprite, drop it into the project, and see it in-game
**without touching any gameplay code.**

---

## 1. Where to put PNGs

```
assets/2d/
  characters/jusup.png            jusup_sheet.png
  characters/scientist.png        scientist_sheet.png
  animals/mouse.png               mouse_sheet.png
  animals/rat.png                 rat_sheet.png
  animals/cat.png                 cat_sheet.png
  tiles/tiles_atlas.png
```

## 2. File naming (exact)

- Single frame: `<name>.png` (e.g. `jusup.png`)
- Animated sheet: `<name>_sheet.png` (e.g. `jusup_sheet.png`)
- All lowercase, underscores only. The `_sheet` suffix is what the pipeline
  looks for — `SpriteAsset.create(base_path)` checks `<base>_sheet.png` first.

## 3. Size

- Frame: **16 × 16 px**.
- Sheet: **128 px wide** (8 columns). Height = rows × 16
  (5 rows → 80 px for Jusup/Scientist, 4 rows → 64 px for animals).
- Row order and frame counts: see `docs/2d/PIXEL_ART_SPEC.md` §5.

## 4. Pivot

- Center of each cell **(8, 8)**. Feet in the lower half of the cell.
- Do not shift art to "fix" position — placement is handled in code.

## 5. Animation naming

You never name animations — the ROW defines them:

| Row | Jusup / Scientist | Animals |
|-----|-------------------|---------|
| 0 | IDLE | IDLE |
| 1 | MOVE / WALK | MOVE |
| 2 | ABSORB / ALERT | HURT |
| 3 | ABILITY / CHASE | ABSORB_REACTION |
| 4 | HURT | — |

Gameplay calls `play("MOVE")`, `play("CHASE")`, etc. Names are strings,
but their row mapping is fixed by the spec.

## 6. How to check an animation

Open the test scene:

```bash
godot --path . res://scenes/2d/pixel_art_test.tscn
```

All five characters stand side by side and automatically cycle through
every state. Each caption shows `SHEET` (your art is loaded) or `FALLBACK`
(placeholder is showing = PNG missing/misnamed).

## 7. Replacing a placeholder

Two options. Both are picked up automatically —
no gameplay code changes ever.

**Option A — one canonical sheet:**
1. Draw the sheet following the spec (grid, pivot, palette, row order).
2. Save it as `<name>_sheet.png` next to the existing `<name>.png`
   (e.g. `assets/2d/characters/jusup_sheet.png`).

**Option B — one file per state (Jusup):**
Put these into `assets/2d/characters/jusup/` (or next to `jusup.png`):
```
jusup_idle_sheet.png    4 frames (64x16)
jusup_move_sheet.png    4 frames (64x16)
jusup_absorb_sheet.png  4 frames (64x16)
jusup_ability_sheet.png 4 frames (64x16)
jusup_hurt_sheet.png    2 frames (32x16)
```
`SpriteAsset` stitches them into the canonical atlas at load time.
Missing states keep the procedural fallback — add files one by one.

Then:
3. Run the project once so Godot imports the PNGs (or open the editor).
4. Delete the sheets and the placeholders return automatically.

## 8. Run the tests

```bash
godot --headless --path . --script res://tests/check_proto2d.gd
godot --headless --path . --script res://tests/check_pipeline.gd
godot --path . res://scenes/2d/jusup_art_test.tscn
```

---

*Rules recap: 16px grid · center pivot · one row per animation ·
fixed row order · 1px dark outline `#1a1420` · ≤16 colors · no gradients.*
