

import json
import os
import shutil
import sys
from pathlib import Path
from datetime import datetime

PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent.parent
CONFIG_PATH = Path(__file__).resolve().parent.parent / "config" / "pipeline_config.json"
MANIFEST_PATH = Path(__file__).resolve().parent.parent / "cache" / "manifest.json"
GENERATED_DIR = Path(__file__).resolve().parent.parent / "generated"
BACKUP_DIR = Path(__file__).resolve().parent.parent / "cache" / "backups"


def load_config() -> dict:
    if CONFIG_PATH.exists():
        with open(CONFIG_PATH) as f:
            return json.load(f)
    return {}


def load_manifest() -> dict:
    if MANIFEST_PATH.exists():
        with open(MANIFEST_PATH) as f:
            return json.load(f)
    return {"assets": {}, "version": 1}


def save_manifest(manifest: dict):
    MANIFEST_PATH.parent.mkdir(parents=True, exist_ok=True)
    with open(MANIFEST_PATH, "w") as f:
        json.dump(manifest, f, indent=2)


def determine_target_dir(filename: str, config: dict) -> str:

    asset_types = config.get("asset_types", {})
    name_lower = filename.lower()

    patterns = {
        "characters": ["character_", "hunter", "jusup", "scientist"],
        "enemies": ["enemy_", "guard", "fast_", "heavy_", "runner", "brute"],
        "animals": ["animal_", "mouse", "rat_", "cat_"],
        "npcs": ["npc_", "citizen", "informant"],
        "tiles": ["tile_", "tiles_atlas", "asphalt", "sidewalk", "road", "wall"],
        "environment": ["env_", "prop_", "fence", "bench"],
        "hud": ["hud_", "hp_", "energy_", "bar_"],
        "ui": ["ui_", "button", "panel", "menu"],
        "backgrounds": ["bg_", "background", "skyline"],
        "clock": ["clock_"],
    }

    for asset_type, keywords in patterns.items():
        if any(kw in name_lower for kw in keywords):
            return asset_types.get(asset_type, {}).get("target_dir", "res://assets/2d")

    return "res://assets/2d"


def backup_existing(target_path: Path):

    if target_path.exists():
        BACKUP_DIR.mkdir(parents=True, exist_ok=True)
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        backup_name = f"{target_path.stem}_{timestamp}{target_path.suffix}"
        backup_path = BACKUP_DIR / backup_name
        shutil.copy2(target_path, backup_path)
        return str(backup_path)
    return None


def res_to_path(res_path: str) -> Path:

    if res_path.startswith("res://"):
        return PROJECT_ROOT / res_path[6:]
    return Path(res_path)


def export_asset(source_path: Path, config: dict = None,
                 dry_run: bool = False, force: bool = False) -> dict:

    if config is None:
        config = load_config()

    export_config = config.get("export", {})
    filename = source_path.name
    target_dir_res = determine_target_dir(filename, config)
    target_dir = res_to_path(target_dir_res)
    target_path = target_dir / filename

    result = {
        "success": False,
        "source": str(source_path),
        "target": str(target_path.relative_to(PROJECT_ROOT)),
        "action": "skip",
        "backup_path": None,
        "error": None
    }

    if not source_path.exists():
        result["error"] = f"Source file not found: {source_path}"
        return result

    if target_path.exists() and not force:
        if export_config.get("overwrite_protection", True):
            result["action"] = "skipped_exists"
            result["error"] = f"Target already exists: {target_path}. Use --force to overwrite."
            return result

    if dry_run:
        result["action"] = "would_export"
        result["success"] = True
        return result

    if target_path.exists() and export_config.get("backup_existing", True):
        result["backup_path"] = backup_existing(target_path)

    target_dir.mkdir(parents=True, exist_ok=True)

    try:
        shutil.copy2(source_path, target_path)
        result["action"] = "exported"
        result["success"] = True
    except Exception as e:
        result["error"] = f"Export failed: {e}"
        return result

    manifest = load_manifest()
    manifest["assets"][filename] = {
        "source": str(source_path),
        "target": str(target_path.relative_to(PROJECT_ROOT)),
        "exported_at": datetime.now().isoformat(),
        "size_bytes": source_path.stat().st_size,
        "target_dir": target_dir_res,
    }
    save_manifest(manifest)

    return result


def export_all(dry_run: bool = False, force: bool = False) -> list:

    config = load_config()
    results = []

    for png in sorted(GENERATED_DIR.rglob("*.png")):
        result = export_asset(png, config, dry_run, force)
        results.append(result)

    return results


def print_export_results(results: list):
    exported = sum(1 for r in results if r["action"] == "exported")
    dry_run_count = sum(1 for r in results if r["action"] == "would_export")
    skipped = sum(1 for r in results if "skip" in r["action"])
    failed = sum(1 for r in results if r.get("error") and r["action"] not in ("exported", "would_export"))

    print(f"\n{'='*60}")
    print(f"  ASSET EXPORT REPORT")
    if dry_run_count > 0:
        print(f"  Would export: {dry_run_count}  Exported: {exported}  Skipped: {skipped}  Failed: {failed}")
    else:
        print(f"  Exported: {exported}  Skipped: {skipped}  Failed: {failed}")
    print(f"{'='*60}\n")

    for r in results:
        if r["action"] == "exported":
            print(f"  ✓ {r['source']} → {r['target']}")
            if r.get("backup_path"):
                print(f"    (backed up: {r['backup_path']})")
        elif r["action"] == "would_export":
            print(f"  ~ {r['source']} → {r['target']} (dry run)")
        elif "skip" in r["action"]:
            print(f"  - {r['source']} (skipped: exists)")
        else:
            print(f"  ✗ {r['source']}: {r.get('error', 'unknown')}")


def main():
    dry_run = "--dry-run" in sys.argv
    force = "--force" in sys.argv
    export_all_flag = "--all" in sys.argv

    paths = [Path(p) for p in sys.argv[1:] if not p.startswith("--")]

    if export_all_flag or not paths:
        results = export_all(dry_run, force)
    else:
        config = load_config()
        results = [export_asset(p, config, dry_run, force) for p in paths]

    print_export_results(results)
    sys.exit(0 if all(r["success"] for r in results) else 1)


if __name__ == "__main__":
    main()
