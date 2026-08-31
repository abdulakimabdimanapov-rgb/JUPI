# AI Asset Pipeline — TIME HUNTER

This tool makes pixel art for the game.

## Quick Start

```bash
python tools/ai/scripts/generate.py all
python tools/ai/scripts/validate_assets.py
python tools/ai/scripts/preview_assets.py
python tools/ai/scripts/export_assets.py --all
```

## Without ComfyUI

Works without AI model — makes colored placeholders.
Validation, export, and gallery all work the same.

## With ComfyUI

```bash
cd /path/to/ComfyUI && python main.py --listen
# Edit tools/ai/config/pipeline_config.json → "enabled": true
```

## Gallery

```bash
godot --path . res://scenes/2d/asset_gallery.tscn
```

## Docs

- `tools/ai/STYLE_GUIDE.md` — visual rules for all assets
- `docs/AI_ASSET_PIPELINE.md` — full pipeline documentation
