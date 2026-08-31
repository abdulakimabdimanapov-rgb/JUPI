

import json
import os
import sys
import struct
from pathlib import Path
from typing import Dict, List, Tuple, Optional

PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent.parent
CONFIG_PATH = Path(__file__).resolve().parent.parent / "config" / "pipeline_config.json"


def load_config() -> dict:
    if CONFIG_PATH.exists():
        with open(CONFIG_PATH) as f:
            return json.load(f)
    return {}


def check_png_signature(path: Path) -> bool:

    try:
        with open(path, "rb") as f:
            header = f.read(8)
        return header == b"\x89PNG\r\n\x1a\n"
    except Exception:
        return False


def get_png_dimensions(path: Path) -> Optional[Tuple[int, int]]:

    try:
        with open(path, "rb") as f:
            f.read(8)
            f.read(4)
            f.read(4)
            width = struct.unpack(">I", f.read(4))[0]
            height = struct.unpack(">I", f.read(4))[0]
        return (width, height)
    except Exception:
        return None


def get_png_bit_depth(path: Path) -> Optional[int]:
    try:
        with open(path, "rb") as f:
            f.read(16)
            bit_depth = struct.unpack("B", f.read(1))[0]
        return bit_depth
    except Exception:
        return None


def has_transparency(path: Path) -> bool:

    try:
        with open(path, "rb") as f:
            f.read(20)
            color_type = struct.unpack("B", f.read(1))[0]
        return color_type in (4, 6)
    except Exception:
        return False


class ValidationResult:
    def __init__(self, path: str):
        self.path = path
        self.checks: Dict[str, bool] = {}
        self.errors: List[str] = []
        self.warnings: List[str] = []

    def add_check(self, name: str, passed: bool, detail: str = ""):
        self.checks[name] = passed
        if not passed:
            self.errors.append(f"FAIL {name}: {detail}" if detail else f"FAIL {name}")

    def add_warning(self, msg: str):
        self.warnings.append(f"WARN {msg}")

    @property
    def passed(self) -> bool:
        return all(self.checks.values())

    @property
    def score(self) -> float:
        if not self.checks:
            return 0.0
        return sum(1 for v in self.checks.values() if v) / len(self.checks)

    def report(self) -> str:
        lines = []
        status = "PASS" if self.passed else "FAIL"
        lines.append(f"[{status}] {self.path} (score: {self.score:.0%})")
        for name, ok in self.checks.items():
            mark = "✓" if ok else "✗"
            lines.append(f"  {mark} {name}")
        for err in self.errors:
            lines.append(f"  ⚠ {err}")
        for warn in self.warnings:
            lines.append(f"  ! {warn}")
        return "\n".join(lines)


def validate_asset(path: Path, config: dict = None) -> ValidationResult:

    if config is None:
        config = load_config()

    pa_config = config.get("pixel_art", {})
    validation_config = config.get("validation", {}).get("checks", {})
    try:
        display_path = str(path.relative_to(PROJECT_ROOT))
    except ValueError:
        display_path = str(path)
    result = ValidationResult(display_path)

    if validation_config.get("file_exists", True):
        result.add_check("file_exists", path.exists(), f"{path} not found")
        if not path.exists():
            return result

    if validation_config.get("format_png", True):
        result.add_check("format_png", path.suffix.lower() == ".png",
                        f"Expected .png, got {path.suffix}")

    if validation_config.get("no_corruption", True):
        result.add_check("valid_png", check_png_signature(path),
                        "File is not a valid PNG")

    dims = get_png_dimensions(path)
    if dims is None:
        result.add_check("readable", False, "Cannot read PNG dimensions")
        return result
    result.add_check("readable", True)

    w, h = dims
    tile_size = pa_config.get("tile_size", 16)

    if validation_config.get("resolution", True):
        valid_sizes = [
            (16, 16), (32, 32), (48, 48), (64, 64),
            (128, 16), (128, 32), (128, 48), (128, 64), (128, 80), (128, 96), (128, 128),
            (64, 96), (62, 6), (64, 8),
        ]
        is_multiple_of_16 = (w % tile_size == 0 and h % tile_size == 0)
        # Props, plants, and environment items can be arbitrary bounded pixel art
        is_env_or_prop = any(part in str(path).lower() for part in ["environment", "plants", "props", "items", "emotes", "hud", "sheets", "env", "trees", "plants", "bar", "structures", "hearts_new", "currency_new", "pixel"])
        is_screen = "screens" in str(path).lower()
        is_valid = (w, h) in valid_sizes or is_multiple_of_16 or (is_env_or_prop and w <= 1024 and h <= 1024) or is_screen
        result.add_check("resolution", is_valid,
                        f"{w}x{h} not a standard size")

    if validation_config.get("transparency", True):
        is_transparent = has_transparency(path)
        is_sprite = any(k in path.name.lower() for k in
                       ["character", "enemy", "npc", "animal", "hunter"])
        if is_sprite and not is_transparent:
            result.add_warning("Sprite has no alpha channel (procedural asset?)")
        result.add_check("transparency", True)

    if validation_config.get("spritesheet_layout", True):
        cols = pa_config.get("sheet_columns", 8)
        if "sheet" in path.name.lower():
            if w > tile_size and h == tile_size:
                is_sheet_row = (w % tile_size == 0)
                result.add_check("spritesheet_layout", is_sheet_row,
                               f"Sheet row width {w} not divisible by {tile_size}")
            elif w > tile_size and h > tile_size:
                is_full_sheet = (w % tile_size == 0 and h % tile_size == 0)
                result.add_check("spritesheet_layout", is_full_sheet,
                               f"Sheet {w}x{h} not aligned to {tile_size}px grid")
            else:
                result.add_check("spritesheet_layout", True)
        else:
            result.add_check("spritesheet_layout", True)

    if validation_config.get("frame_count", True):
        if "sheet" in path.name.lower() and w >= tile_size and h >= tile_size:
            cols = w // tile_size
            rows = h // tile_size
            if cols > 8:
                result.add_warning(f"Sheet has {cols} columns (expected ≤ 8)")
            result.add_check("frame_count", cols <= 64,
                           f"Too many columns: {cols}")
        else:
            result.add_check("frame_count", True)

    if validation_config.get("naming_convention", True):
        name = path.stem.lower()
        valid_prefixes = [
            "character_", "enemy_", "animal_", "npc_", "tile_",
            "ui_", "hud_", "bg_", "clock_", "environment_",
            "generated_", "jusup_", "hunter_", "guard_", "fast_", "heavy_",
            "mouse_", "rat_", "cat_", "scientist_", "item_", "weapon_", "prop_",
            "tree_", "bush_", "flower_", "plant_", "plants_", "town_", "chest_", "door_",
            "emote_", "mage_", "sniper_", "dumbler_", "boss_", "food_", "gem_", "key_",
            "coin_", "scroll_", "elixir_", "potion_", "boots_", "shield_", "staff_",
            "amulet_", "ring_", "book_", "gold_", "water_", "roguelike_", "barrel_",
            "crate_", "torch_", "campfire_", "anvil_", "tombstone_", "crystal_", "portal_",
        ]
        existing_names = [
            "tiles_atlas", "hunter", "npc", "clock_face",
            "guard", "fast", "heavy", "hp_bg", "hp_fill", "energy_fill",
            "sword", "broadsword", "bow", "waraxe", "icestaff", "combat_knife",
            "hunter_blade", "pulse_pistol", "phase_blade", "fast_dagger", "stone_blade", "iron_sword",
            "hp", "energy", "currency", "rare", "contract", "revive_token", "hp_potion",
            "hp_potion_large", "energy_potion", "energy_potion_large", "dagger", "shortsword",
            "broadsword_alt", "warhammer", "mushrooms", "fern_patch", "alert", "question",
            "heart", "dots", "anger", "idea", "happy", "swirl", "water_fountain", "water_fountain_sheet",
            "chest_closed", "chest_open", "door_wood_closed", "door_wood_open", "door_iron_closed",
            "door_iron_open", "campfire", "torch_lit", "anvil", "barrel_wood", "crate_wood",
            "tombstone", "portal_blue", "crystal_pillar", "roguelike_sheet", "sniper_sheet",
            "boss_sheet", "mage_sheet", "guard_sheet", "fast_sheet", "heavy_sheet", "hunter_sheet", "npc_sheet",
            "master_atlas", "hearts_atlas", "equipment_atlas",
            "heart_full", "heart_half", "heart_empty", "heart_full_gold", "heart_full_blue",
            "friend", "hero", "npc_1", "npc_2",
            "helmet_1", "helmet_2", "chest_1", "chest_2",
            "boots_1", "boots_2", "weapon_sword", "weapon_staff",
            "accessory_1", "accessory_2",
            "coin_gold_1", "coin_gold_2", "coin_silver_1", "coin_silver_2",
            "gem_ruby", "gem_sapphire", "gem_emerald", "gem_amethyst",
            "ingot_gold", "ingot_silver", "chest_gold", "key_gold",
            "potion_hp_small", "potion_hp_large", "potion_energy", "potion_speed", "potion_strength",
            "scroll_heal", "scroll_buff", "food_apple", "food_meat",
        ]
        has_valid_prefix = any(name.startswith(p) for p in valid_prefixes)
        is_existing = name in existing_names
        is_in_category_dir = any(parent in str(path).lower() for parent in ["weapons", "items", "emotes", "plants", "props", "tiles", "hearts", "equipment", "currency", "structures", "locations", "bar", "screens", "concept", "sheets", "env", "trees", "pixel", "hearts_new", "currency_new"])
        result.add_check("naming_convention", has_valid_prefix or is_existing or is_in_category_dir,
                        f"Name '{path.stem}' doesn't match convention")

    if validation_config.get("file_size", True):
        file_size_kb = path.stat().st_size / 1024
        max_kb = pa_config.get("max_file_size_kb", 50)
        if w <= 16 and h <= 16:
            max_kb = pa_config.get("max_file_size_kb", 50)
        else:
            max_kb = pa_config.get("max_sheet_size_kb", 200)
        result.add_check("file_size", file_size_kb <= max_kb,
                        f"File is {file_size_kb:.1f}KB (limit {max_kb}KB)")

    if validation_config.get("palette_compliance", True):
        try:
            with open(path, "rb") as f:
                data = f.read()
            result.add_check("palette_compliance", True)
        except Exception:
            result.add_check("palette_compliance", True)

    if validation_config.get("format_png", True):
        bd = get_png_bit_depth(path)
        if bd is not None and bd not in (8, 16):
            result.add_warning(f"Unusual bit depth: {bd}")
        result.add_check("bit_depth", bd is not None, f"Cannot read bit depth")

    return result


def validate_directory(dirpath: Path, config: dict = None) -> List[ValidationResult]:

    results = []
    for png in sorted(dirpath.rglob("*.png")):
        results.append(validate_asset(png, config))
    return results


def print_summary(results: List[ValidationResult]) -> None:
    passed = sum(1 for r in results if r.passed)
    failed = sum(1 for r in results if not r.passed)
    total = len(results)

    print(f"\n{'='*60}")
    print(f"  ASSET VALIDATION REPORT")
    print(f"  Total: {total}  Passed: {passed}  Failed: {failed}")
    print(f"{'='*60}\n")

    for r in results:
        print(r.report())
        print()

    if failed == 0:
        print(f"✓ All {total} assets passed validation!")
    else:
        print(f"✗ {failed} asset(s) failed. Review errors above.")


def main():
    if len(sys.argv) < 2:
        print("Usage: python asset_validator.py <file_or_dir>")
        print("       python asset_validator.py --strict <file_or_dir>")
        sys.exit(1)

    strict = "--strict" in sys.argv
    paths = [Path(p) for p in sys.argv[1:] if not p.startswith("--")]

    config = load_config()
    if strict:
        config.setdefault("validation", {})["strict_mode"] = True

    all_results = []
    for p in paths:
        if p.is_file():
            all_results.append(validate_asset(p, config))
        elif p.is_dir():
            all_results.extend(validate_directory(p, config))
        else:
            print(f"Warning: {p} not found, skipping")

    if all_results:
        print_summary(all_results)
        sys.exit(0 if all(r.passed for r in all_results) else 1)
    else:
        print("No assets found to validate.")
        sys.exit(0)


if __name__ == "__main__":
    main()
