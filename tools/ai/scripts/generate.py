

import json
import os
import sys
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent.parent
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from generators.comfyui_adapter import ComfyUIAdapter, FallbackGenerator
from validators.asset_validator import validate_asset, load_config

CONFIG_PATH = Path(__file__).resolve().parent.parent / "config" / "pipeline_config.json"
PROMPTS_DIR = Path(__file__).resolve().parent.parent / "prompts"
GENERATED_DIR = Path(__file__).resolve().parent.parent / "generated"


def load_prompt_template(category: str) -> str:

    prompt_file = PROMPTS_DIR / f"{category}.txt"
    if prompt_file.exists():
        return prompt_file.read_text().strip()
    return "pixel art, 16x16, top-down, {description}, dark cyberpunk, flat colors, 1px outline, transparent background"


def build_prompt(category: str, name: str, description: str, **kwargs) -> str:

    template = load_prompt_template(category)

    params = {
        "character_name": name,
        "enemy_type": name,
        "animal_type": name,
        "npc_type": name,
        "tile_type": name,
        "ui_type": name,
        "description": description or f"{name} game asset",
        "state": "idle",
        "frame_index": "0",
        "total_frames": "4",
        "width": "16",
        "height": "16",
        "scene_description": description or f"{name} environment",
        "subject_description": description or f"{name} game asset",
    }
    params.update(kwargs)

    prompt = template
    for key, value in params.items():
        prompt = prompt.replace(f"{{{key}}}", str(value))

    return prompt


def generate_asset(category: str, name: str, description: str = "",
                  workflow: str = None, params: dict = None) -> dict:

    config = load_config()
    adapter = ComfyUIAdapter(config)

    if workflow is None:
        workflow_map = {
            "character": "character_sheet",
            "enemy": "character_sheet",
            "animal": "character_sheet",
            "npc": "character_sheet",
            "tile": "tile_generator",
            "environment": "tile_generator",
            "ui": "pixel_art_16x16",
            "background": "pixel_art_16x16",
            "animation": "character_sheet",
        }
        workflow = workflow_map.get(category, "pixel_art_16x16")

    prompt = build_prompt(category, name, description)

    print(f"\n{'='*60}")
    print(f"  Generating: {category}/{name}")
    print(f"  Workflow: {workflow}")
    print(f"  Prompt: {prompt[:100]}...")
    print(f"{'='*60}\n")

    if adapter.is_available():
        print("  Using ComfyUI backend...")
        result = adapter.generate(prompt, workflow, params=params)
        if result.get("success"):
            print(f"  ✓ Generated: {result['output_path']}")
            from pathlib import Path as P
            validation = validate_asset(P(result["output_path"]), config)
            print(f"  Validation: {'PASS' if validation.passed else 'FAIL'} (score: {validation.score:.0%})")
            return result
        else:
            print(f"  ✗ ComfyUI failed: {result.get('error')}")
            print("  Falling back to procedural generation...")

    print("  Using fallback generator...")
    gen = FallbackGenerator(GENERATED_DIR)
    output_path = gen.generate_character_placeholder(name)
    if output_path:
        print(f"  ✓ Generated placeholder: {output_path}")
        return {"success": True, "output_path": output_path, "fallback": True}
    else:
        return {"success": False, "error": "Both ComfyUI and fallback failed"}


ASSET_DEFINITIONS = {
    "characters": [
        ("hunter", "Professional time-traveling assassin, dark coat, glowing weapon"),
        ("scientist", "Lab coat, green badge, nervous expression"),
    ],
    "enemies": [
        ("guard", "Armored soldier with helmet, balanced stats"),
        ("fast", "Masked agile fighter, glowing green eyes, red scarf"),
        ("heavy", "Massive armored brute, red visor, heavy boots"),
    ],
    "animals": [
        ("mouse", "Tiny pale grey mouse, huge ears, pink inner"),
        ("rat", "Hunched brown rat, thick pink tail, red eyes"),
        ("cat", "Wide ginger cat, dark stripes, calm narrow eyes"),
    ],
    "npcs": [
        ("informant", "Street informant, blue-grey clothing, nervous"),
        ("citizen", "Ordinary city resident, neutral colors"),
    ],
    "tiles": [
        ("wall_brick", "Weathered brick wall, dark cyberpunk city"),
        ("neon_sign", "Glowing neon sign, red/pink glow"),
        ("puddle", "Reflective puddle on dark asphalt"),
    ],
}


def generate_all():

    results = []
    for category, assets in ASSET_DEFINITIONS.items():
        for name, desc in assets:
            result = generate_asset(category, name, desc)
            results.append(result)
    return results


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)

    command = sys.argv[1]

    if command == "all":
        results = generate_all()
        succeeded = sum(1 for r in results if r.get("success"))
        print(f"\n{'='*60}")
        print(f"  Generated {succeeded}/{len(results)} assets")
        print(f"{'='*60}")
    elif command == "character" and len(sys.argv) >= 3:
        name = sys.argv[2]
        desc = sys.argv[3] if len(sys.argv) > 3 else ""
        generate_asset("character", name, desc)
    elif command == "enemy" and len(sys.argv) >= 3:
        name = sys.argv[2]
        desc = sys.argv[3] if len(sys.argv) > 3 else ""
        generate_asset("enemy", name, desc)
    elif command == "animal" and len(sys.argv) >= 3:
        name = sys.argv[2]
        desc = sys.argv[3] if len(sys.argv) > 3 else ""
        generate_asset("animal", name, desc)
    elif command == "npc" and len(sys.argv) >= 3:
        name = sys.argv[2]
        desc = sys.argv[3] if len(sys.argv) > 3 else ""
        generate_asset("npc", name, desc)
    elif command == "tile" and len(sys.argv) >= 3:
        name = sys.argv[2]
        desc = sys.argv[3] if len(sys.argv) > 3 else ""
        generate_asset("tile", name, desc)
    elif command == "environment" and len(sys.argv) >= 3:
        name = sys.argv[2]
        desc = sys.argv[3] if len(sys.argv) > 3 else ""
        generate_asset("environment", name, desc)
    elif command == "ui" and len(sys.argv) >= 3:
        name = sys.argv[2]
        desc = sys.argv[3] if len(sys.argv) > 3 else ""
        generate_asset("ui", name, desc)
    elif command == "background" and len(sys.argv) >= 3:
        name = sys.argv[2]
        desc = sys.argv[3] if len(sys.argv) > 3 else ""
        generate_asset("background", name, desc)
    else:
        print(f"Unknown command: {command}")
        print(__doc__)
        sys.exit(1)


if __name__ == "__main__":
    main()
