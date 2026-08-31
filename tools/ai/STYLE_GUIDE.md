# STYLE GUIDE — TIME HUNTER: THE BLOOD CLOCK

This is the main guide for all visual assets in the game.
All tools and workflows use this document.

---

## 1. Grid & Resolution

| Parameter | Value |
|-----------|-------|
| Base tile | **16 × 16 px** |
| Sprite canvas | **16 × 16 px per frame** |
| Sheet layout | **8 columns × N rows** of 16 px cells (128 px wide) |
| One animation = one row | Frames fill left→right, unused cells stay empty |
| Rendering | `TEXTURE_FILTER_NEAREST`, no smoothing, no mipmaps |
| Background | **Transparent** (RGBA8) for characters/enemies/props |

### Exceptions

| Asset type | Canvas size | Notes |
|------------|-------------|-------|
| Tile atlas | 128 × 80 px | 8×5 grid of 16px tiles |
| HUD elements | Variable (64×8, 62×6) | Bar fills, backgrounds |
| Clock face | 32 × 32 px | Decorative element |
| UI panels | 500+ px wide | Screen-space overlays |

---

## 2. Pivot

- **Pivot = center of the cell: (8, 8).**
- Feet/body mass sit in the lower half (y ≈ 10–13).
- Do NOT bake offsets into art. Placement handled in code.

---

## 3. Direction / Orientation

- Default facing: **UP (north)** for animals (top-down).
- Characters (Hunter, NPCs) are top-down blobs — head toward north.
- Horizontal movement mirrors with `flip_h` in code — draw ONE side only.
- Never draw separate left/right rows.

---

## 4. Frame Counts & FPS (Fixed)

| Animation | Frames | FPS | Loop |
|-----------|--------|-----|------|
| IDLE | 4 | 6 | yes |
| MOVE / WALK | 4 | 10 | yes |
| ATTACK | 4 | 10 | no |
| ALT_ATTACK | 4 | 12 | no |
| DODGE | 4 | 12 | no |
| HURT | 2 | 10 | no |
| DEATH | 4 | 8 | no |
| INTERACT | 2 | 6 | no |
| ABILITY | 4 | 12 | no |
| ALERT | 2 | 6 | yes |
| CHASE | 4 | 12 | yes |
| ABSORB | 4 | 10 | no |
| ABSORB_REACTION | 4 | 12 | no |

Animal species may run IDLE/MOVE at personality FPS
(mouse ≈ 12–14, rat ≈ 5–7, cat ≈ 7–9); frame COUNT never changes.

---

## 5. Row Order Per Sheet (Fixed — Code Depends on It)

### Player (Hunter)
```
row0 IDLE · row1 MOVE · row2 ATTACK · row3 ALT_ATTACK · row4 HURT
```

### Enemies
```
row0 IDLE · row1 MOVE · row2 ATTACK · row3 HURT · row4 DEATH
```

### Animals (mouse/rat/cat)
```
row0 IDLE · row1 MOVE · row2 HURT · row3 ABSORB_REACTION
```

### NPCs
```
row0 IDLE · row1 WALK · row2 ALERT · row3 CHASE · row4 HURT
```

---

## 6. Scale Relative to Tile

| Character | Body fills | ≈ tiles |
|-----------|-----------|---------|
| Mouse | 9–11 px | 0.6 |
| Rat / Cat | 12 px | 0.75 |
| Hunter (Jusup) | 13 px | 0.8 |
| Scientist | 14 px | 0.9 |
| Guard enemy | 12–14 px | 0.8 |
| Heavy enemy | 14–16 px | 0.9 |

---

## 7. Outline Rules

- Every sprite gets a **1 px dark outline**: `#1a1420` (near-black warm).
- Outline follows silhouette only — no inner outlines.
- No anti-aliasing between outline and fill (clean pixel steps).

---

## 8. Lighting & Shading

- Flat colors + **one highlight + one shadow shade per material**, max.
- Light source: **implicit top-left** (highlights top/left, shadows bottom/right).
- No gradients, no baked directional light, no glow layers.
- Exceptions: neon signs (glow pixels allowed), bio-core (mint glow).

---

## 9. Shadows

- No baked drop shadows inside the sprite.
- Ground shadows are separate ellipse decals by the engine.
- Keep the cell clean below the feet.

---

## 10. Color Rules

- Palette budget: **≤ 16 colors per sprite**, ≤ 6 per material.
- Shared global hues:

| Element | Hue family | Example |
|---------|-----------|---------|
| Grass/flora | Green | `#529147` |
| Bio-core (Jusup) | Mint/teal | `#8cffd9` |
| Danger/alert | Red | `#ff4033` |
| Lab greys | Steel | `#8d94a0` |
| Night/city | Dark blue-purple | `#1a1420` |
| Neon | Cyan/magenta | `#00e5ff` / `#ff00ff` |
| Blood/clock | Crimson | `#cc2211` |

- Keep saturation moderate.
- Neon only for bio-core and UI accents.

---

## 11. Per-Character Palettes

| Sprite | Outline | Body | Accent |
|--------|---------|------|--------|
| HUNTER | `#1a1424` | coat `#2e1f42` + hi `#4c3870` | bio-core `#8cffd9`, weapon `#8899aa` |
| GUARD | `#211a17` | armor `#403530` + hi `#4d403a` | helmet `#2a2c2e` |
| FAST | `#211a17` | body `#282e28` + hi `#353e35` | eyes `#33ee55`, scarf `#991a1a` |
| HEAVY | `#211a17` | armor `#423a36` + hi `#504438` | visor `#cc1a11` |
| NPC | `#1a1420` | body `#586670` + hi `#667a85` | belt `#806848` |
| HUNTER_CLOAK | `#1a1424` | cloak `#252830` + hi `#303340` | buckle `#b3aa55` |

---

## 12. Environment Tiles

| Tile | Purpose | Palette |
|------|---------|---------|
| ASPHALT | Road surface | `#2e2e33` |
| SIDEWALK | Pedestrian path | `#595652` |
| ROAD | Driveway | `#232328` |
| WALL_BRICK | Building walls | `#6b5147` |
| WALL_DARK | Dark walls | `#51474d` |
| PUDDLE | Water reflection | `#2e3859` |
| GRASS_PATCH | Vegetation | `#2e4d26` |
| CONCRETE | Interior floor | `#66666b` |
| BLDG_MODERN | Modern facade | `#4d5261` |
| BLDG_FUTURE | Near-future facade | `#384059` |
| NEON_ON/FF | Neon signs | `#e64050` / `#3399e6` |
| DOOR | Entry points | `#594838` |
| WINDOW_LIT | Illuminated window | `#d9bf73` |
| WINDOW_DARK | Dark window | `#1e2633` |

---

## 13. Naming Convention

```
<type>_<name>_<variant>.png          # single frame
<type>_<name>_sheet.png              # animated sheet (canonical)
<type>_<name>_<anim>_sheet.png       # per-state sheet (stitchable)
```

Examples:
- `character_hunter.png` — single idle frame
- `character_hunter_sheet.png` — full animation sheet
- `enemy_guard_sheet.png` — guard enemy sheet
- `tile_asphalt.png` — single tile
- `tile_atlas.png` — full tile atlas
- `ui_hp_bar.png` — HUD element
- `bg_city_night.png` — background

---

## 14. Export Format

- **PNG** with alpha channel (RGBA8).
- **No compression artifacts** — lossless only.
- **No embedded metadata** beyond standard PNG chunks.
- File size target: < 50 KB per 16×16 sprite, < 200 KB per sheet.

---

## 15. Lighting Direction

All sprites must share the same implicit light direction:
- **Top-left** light source.
- Highlights on top/left edges.
- Shadows on bottom/right.
- This applies to characters, enemies, objects, and tiles.

---

## 16. Consistency Checklist

Before accepting any asset:

- [ ] Correct resolution (16×16 or specified size)
- [ ] Transparent background (for sprites)
- [ ] 1px dark outline `#1a1420`
- [ ] Flat colors, max 16 per sprite
- [ ] Top-left lighting
- [ ] No gradients
- [ ] No anti-aliasing
- [ ] Matches character palette from §11
- [ ] Fits within tile scale from §6
- [ ] Can tile correctly (for environment tiles)
- [ ] PNG format, RGBA8, no artifacts
