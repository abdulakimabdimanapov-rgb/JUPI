# PIXEL ART SPEC — JUPI 2D

This is the main guide for every 2D sprite in the project.
Everything below is fixed so all sprites look like one set.

---

## 1. Grid & resolution

| Parameter | Value |
|-----------|-------|
| Base tile | **16 × 16 px** |
| Sprite canvas | 16 × 16 px per frame |
| Sheet layout | **8 columns × N rows** of 16 px cells (128 px wide) |
| One animation | = one row; frames fill left→right, unused cells stay empty |
| Rendering | `TEXTURE_FILTER_NEAREST`, no smoothing, no mipmaps |

## 2. Pivot

- **Pivot = center of the cell: (8, 8).**
- Feet/body mass should sit in the lower half (y ≈ 10–13).
- Do NOT bake offsets into art; position entities at tile centers in code.

## 3. Direction / orientation

- Default facing: **UP (north)** for animals (matches current top-down set);
  characters (Jusup, Scientist) are top-down blobs — head toward north.
- Horizontal movement mirrors with `flip_h` in code — draw ONE side only.
- Never draw separate left/right rows.

## 4. Frame counts & FPS (fixed)

| Animation | Frames | FPS | Loop |
|-----------|--------|-----|------|
| IDLE | 4 | 6 | yes |
| MOVE / WALK | 4 | 10 | yes |
| ABSORB | 4 | 10 | no |
| ABILITY | 4 | 12 | no |
| HURT | 2 | 10 | no |
| ALERT | 2 | 6 | yes |
| CHASE | 4 | 12 | yes |
| ABSORB_REACTION | 4 | 12 | no |

Animal species may run IDLE/MOVE at their personality FPS
(mouse ≈ 12–14, rat ≈ 5–7, cat ≈ 7–9); frame COUNT never changes.

## 5. Row order per sheet (fixed — code depends on it)

```
jusup_sheet.png     row0 IDLE · row1 MOVE · row2 ABSORB · row3 ABILITY · row4 HURT
mouse/rat/cat_sheet row0 IDLE · row1 MOVE · row2 HURT · row3 ABSORB_REACTION
scientist_sheet.png row0 IDLE · row1 WALK · row2 ALERT · row3 CHASE · row4 HURT
```

## 6. Scale relative to tile

- Small animals (mouse): body fills ~9–11 px → **≈ 0.6 tile**.
- Rat / cat: ~12 px → **0.75 tile**.
- Jusup: ~13 px → **0.8 tile** (slightly larger than prey).
- Scientist: ~14 px → **0.9 tile** (menace through size).

## 7. Outline rules

- Every sprite gets a **1 px dark outline**: `#1a1420` (near-black warm).
- Outline follows the silhouette only; no inner outlines.
- No anti-aliasing between outline and fill (clean pixel steps).

## 8. Lighting & shading

- Flat colors + **one highlight + one shadow shade per material**, max.
- Light source is implicit top-left: highlights on top/left edges,
  shadows bottom/right.
- No gradients, no baked directional light, no glow layers.

## 9. Shadows

- No baked drop shadows inside the sprite.
- If a ground shadow is needed later it will be drawn as a separate ellipse
  decal by the engine — keep the cell clean below the feet.

## 10. Color rules

- Palette budget: **≤ 16 colors per sprite**, ≤ 6 per material.
- Shared global hues so the set feels unified:
  - grass/flora greens: base `#529147` family
  - Jusup bio-core: mint/teal `#8cffd9` family
  - danger/alert reds: `#ff4033` family (UI + CHASE states)
  - lab greys: `#8d94a0` family
- Keep saturation moderate; neon only for the bio-core and UI accents.

---

## 11. Per-character palettes

All colors are the fallback-generator values; hand-drawn sheets must match
these hue families so replacement art reads as the same character.

| Sprite | Outline | Body | Accent / identity |
|--------|---------|------|--------------------|
| JUSUP | `#1a1424` | `#2e1f42` + hi `#4c3870` | bio-core mint `#8cffd9` (ability: `#b3ff80`), 4 tendrils |
| RAT | `#211a17` | brown `#756050`, spine stripe darker | thick pink tail `#b8857a`, RED eyes `#731414` |
| CAT | `#29190d` | ginger `#c28040` | dark stripes, curled tail, calm narrow eyes |
| MOUSE | `#292424` | pale grey `#c7c2b8` | huge ears w/ pink inner, hair-thin tail |
| SCIENTIST | (coat edge) | coat `#e0e6ef` | green badge `#338c4d` |

Silhouette rules: rat = hunched + heavy low body; mouse = tiny + round +
big ears; cat = wide smooth mass; jusup = irregular blob with tendrils.
The four must never be confused in a screenshot.

---

## Prototype 07 — atlas row 4 (zone identity / lab / landmarks)

| Cell | Tile | Purpose |
|------|------|---------|
| (0,4) | MEADOW_G | warmer meadow grass — meadow zone identity |
| (1,4) | DRY_G | withered grass — outskirts identity |
| (2,4) | LAB_TABLE | solid bench with vials (collision) |
| (3,4) | CONTAINER | solid bio-container, glowing specimen (collision) |
| (4,4) | SIGN | roadside landmark sign |
| (5,4) | GLADE | sunlit forest clearing floor (stone-circle landmark) |
| (6,4) | SCATTER | walkable lab clutter: papers, dropped tool |
| (7,4) | ROCK_ALT | second boulder shape, same palette as ROCK |

Zone rule: FOREST reads dark (`FOREST_GROUND` + GLADE landmark), MEADOW warm,
LAKE blue with SAND shore, ROAD pale dirt with TRACKS, OUTSKIRTS withered
(`DRY_G` under the treeline), LABORATORY grey-steel and densest in detail.

---

*Gameplay never loads PNGs directly — see `SpriteAsset` /
`AnimationController2D`. Missing sheets fall back to placeholders
automatically (`docs/2d/ARTIST_WORKFLOW.md`).*
