# AI ASSET PIPELINE — TIME HUNTER: THE BLOOD CLOCK

This system makes visual assets for the game using local AI tools.

---

## Architecture

```
tools/ai/
├── README.md                   # Quick reference
├── STYLE_GUIDE.md              # Visual rules for all assets
├── config/
│   └── pipeline_config.json    # Pipeline settings
├── workflows/
│   ├── pixel_art_16x16.json    # Single sprite generation
│   ├── character_sheet.json    # Character sheets
│   └── tile_generator.json     # Tile atlas generation
├── prompts/
│   ├── character.txt           # Character prompt template
│   ├── enemy.txt               # Enemy prompt template
│   ├── animal.txt              # Animal template
│   ├── npc.txt                 # NPC template
│   ├── environment.txt         # Environment tile template
│   ├── laboratory.txt          # Lab props template
│   ├── pixel_art.txt           # Master pixel art style prompt
│   ├── animation.txt           # Animation frame template
│   ├── ui.txt                  # UI/HUD element template
│   └── background.txt          # Background scene template
├── generators/
│   └── comfyui_adapter.py      # ComfyUI adapter + fallback generator
├── validators/
│   └── asset_validator.py      # Validates assets against STYLE_GUIDE
├── exporters/
│   └── asset_exporter.py       # Copies validated assets to project dirs
├── scripts/
│   ├── generate.py             # CLI: generate assets
│   ├── validate_assets.py      # CLI: validate assets
│   ├── preview_assets.py       # CLI: preview asset report
│   ├── stitch_sheet.py         # CLI: stitch animation rows into sheets
│   └── asset_gallery.gd        # Godot: visual gallery scene
├── cache/
│   └── manifest.json           # Export manifest (auto-generated)
└── generated/                  # Output directory for AI-generated assets
    ├── characters/
    ├── enemies/
    ├── animals/
    ├── npcs/
    ├── tiles/
    ├── environment/
    ├── ui/
    ├── hud/
    └── backgrounds/
```

---

## Installation

### Prerequisites

- Python 3.8+ (for CLI tools)
- Godot 4.7+ (for project and gallery scene)
- ComfyUI (optional, for AI generation)

### ComfyUI Setup (Optional)

```bash
git clone https://github.com/comfyanonymous/ComfyUI.git
cd ComfyUI
pip install -r requirements.txt
python main.py --listen 0.0.0.0 --port 8188
```

Edit `tools/ai/config/pipeline_config.json`:
```json
"comfyui": { "enabled": true }
```

### Without ComfyUI

The pipeline works without ComfyUI using fallback generation.
All CLI commands and validation work the same.

---

## Usage

### Generate Assets

```bash
python tools/ai/scripts/generate.py character hunter "dark-coated assassin"
python tools/ai/scripts/generate.py enemy guard "armored soldier"
python tools/ai/scripts/generate.py tile wall_brick "weathered brick"
python tools/ai/scripts/generate.py all
```

### Validate Assets

```bash
python tools/ai/scripts/validate_assets.py
python tools/ai/scripts/validate_assets.py tools/ai/generated/characters/hunter.png
python tools/ai/scripts/validate_assets.py --all
python tools/ai/scripts/validate_assets.py --strict
```

### Preview Assets

```bash
python tools/ai/scripts/preview_assets.py
python tools/ai/scripts/preview_assets.py --manifest
```

### Export to Project

```bash
python tools/ai/scripts/export_assets.py --all
python tools/ai/scripts/export_assets.py --dry-run --all
python tools/ai/scripts/export_assets.py --force <file>
```

### Stitch Animation Sheets

```bash
python tools/ai/scripts/stitch_sheet.py character_hunter_sheet.png \
    hunter_idle_sheet.png hunter_move_sheet.png hunter_attack_sheet.png
python tools/ai/scripts/stitch_sheet.py --from-dir assets/2d/characters/ hunter_sheet.png
```

### Visual Gallery (Godot)

```bash
godot --path . res://scenes/2d/asset_gallery.tscn
```

---

## Workflow

### Standard Pipeline

```
GENERATE → VALIDATE → PREVIEW → ACCEPT/REJECT → EXPORT → IMPORT
```

1. **Generate**: Run `generate.py` with category, name, and description
2. **Validate**: Run `validate_assets.py` to check against STYLE_GUIDE
3. **Preview**: Open gallery or run `preview_assets.py`
4. **Accept/Reject**: If validation passes, proceed. If not, regenerate.
5. **Export**: Run `export_assets.py --all` to copy to project dirs
6. **Import**: Godot auto-imports on next editor open.

### ComfyUI Workflow

1. Generate one animation row at a time (8 frames, 16×16)
2. Use `stitch_sheet.py` to combine rows into full sheet
3. Validate the stitched sheet
4. Export to project asset directory

### Fallback Generation

When ComfyUI is not available:
1. `generate.py` uses `FallbackGenerator` for colored placeholders
2. Validation still runs
3. Export still works
4. Gameplay uses `SpriteLib2D` fallback (procedural placeholders)

---

## Asset Naming Convention

```
<type>_<name>.png              # single frame
<type>_<name>_sheet.png        # full animated sheet
<type>_<name>_<anim>_sheet.png # per-animation row (stitchable)
```

| Type | Examples |
|------|----------|
| character | `character_hunter.png`, `character_hunter_sheet.png` |
| enemy | `enemy_guard.png`, `enemy_guard_sheet.png` |
| animal | `animal_mouse.png`, `animal_mouse_sheet.png` |
| tile | `tile_asphalt.png`, `tile_wall_brick.png` |
| ui | `ui_hp_bar.png`, `ui_button.png` |
| hud | `hud_energy_fill.png` |
| bg | `bg_city_night.png` |

---

## Prompt Templates

Prompts in `tools/ai/prompts/` use `{placeholder}` syntax:

| Placeholder | Description |
|-------------|-------------|
| `{character_name}` | Character identifier |
| `{enemy_type}` | Enemy class |
| `{animal_type}` | Animal species |
| `{description}` | Free-text description |
| `{state}` | Animation state (idle, walk, attack...) |
| `{frame_index}` | Current frame number |
| `{total_frames}` | Total frames in animation |

---

## Validation Checks

| Check | Description |
|-------|-------------|
| file_exists | File is present |
| format_png | File is .png |
| valid_png | PNG signature valid |
| readable | PNG headers parseable |
| resolution | Matches expected dimensions |
| transparency | Alpha channel present (sprites) |
| spritesheet_layout | Aligned to 16px grid |
| frame_count | ≤ 8 columns per row |
| naming_convention | Matches project naming |
| file_size | Under size limit |
| bit_depth | 8-bit per channel |
| palette_compliance | Color count reasonable |

---

## Integration with Game Pipeline

```
AI-generated PNG
    ↓ (exported to assets/2d/)
SpriteLib2D.tex("res://assets/2d/characters/hunter.png")
    ↓ (loaded or fallback)
SpriteAsset.create(base_path, anims)
    ↓ (resolves sheet or fallback)
AnimationController2D.play("IDLE")
```

The game never knows if an asset was AI-generated or hand-drawn.
Missing assets fall back to procedural placeholders automatically.

---

## Troubleshooting

### "ComfyUI is not running"
- Start ComfyUI: `cd ComfyUI && python main.py --listen`
- Or use fallback: the pipeline generates procedural placeholders

### "Asset failed validation"
- Check `STYLE_GUIDE.md` for requirements
- Common issues: wrong resolution, missing transparency, bad naming

### "Asset not showing in game"
- Run `export_assets.py --all` to copy to project dirs
- Reopen Godot editor to trigger import
- Check that `SpriteLib2D` path matches exported location

### "Gallery scene won't open"
- Ensure Godot 4.7+ is installed
- Run from project root: `godot --path . res://scenes/2d/asset_gallery.tscn`

---

## Adding New Asset Types

1. Add type definition to `config/pipeline_config.json` → `asset_types`
2. Create prompt template in `prompts/<type>.txt`
3. Add workflow if needed in `workflows/`
4. Add naming pattern to `exporters/asset_exporter.py` → `determine_target_dir`
5. Update `STYLE_GUIDE.md` with type-specific rules

---

## File Structure After Generation

```
assets/2d/
├── characters/
│   ├── hunter.png              (existing procedural)
│   ├── hunter_sheet.png        (AI-generated, if accepted)
│   └── npc.png                 (existing procedural)
├── enemies/
│   ├── guard.png               (existing procedural)
│   ├── guard_sheet.png         (AI-generated)
│   └── ...
├── tiles/
│   ├── tiles_atlas.png         (existing procedural)
│   └── ...
└── ...
```
