

import json
import os
import sys
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent.parent
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from validators.asset_validator import get_png_dimensions, load_config

GENERATED_DIR = Path(__file__).resolve().parent.parent / "generated"
MANIFEST_PATH = Path(__file__).resolve().parent.parent / "cache" / "manifest.json"


def scan_generated(detailed: bool = False) -> list:

    assets = []
    for png in sorted(GENERATED_DIR.rglob("*.png")):
        info = {
            "path": str(png.relative_to(GENERATED_DIR)),
            "size_bytes": png.stat().st_size,
        }
        dims = get_png_dimensions(png)
        if dims:
            info["width"] = dims[0]
            info["height"] = dims[1]
        assets.append(info)
    return assets


def scan_project_assets(detailed: bool = False) -> list:

    assets = []
    assets_dir = PROJECT_ROOT / "assets" / "2d"
    if not assets_dir.exists():
        return assets
    for png in sorted(assets_dir.rglob("*.png")):
        info = {
            "path": str(png.relative_to(PROJECT_ROOT)),
            "size_bytes": png.stat().st_size,
            "source": "canonical"
        }
        dims = get_png_dimensions(png)
        if dims:
            info["width"] = dims[0]
            info["height"] = dims[1]
        assets.append(info)
    return assets


def print_gallery(generated: list, project: list):
    print(f"\n{'='*70}")
    print(f"  TIME HUNTER — AI ASSET GALLERY")
    print(f"{'='*70}\n")

    if project:
        print(f"  PROJECT ASSETS ({len(project)} files):")
        print(f"  {'─'*66}")
        for a in project:
            dims = f"{a.get('width', '?')}x{a.get('height', '?')}" if 'width' in a else "?"
            size_kb = a['size_bytes'] / 1024
            print(f"    {a['path']:<45} {dims:>8}  {size_kb:>6.1f}KB")
        print()

    if generated:
        print(f"  GENERATED ASSETS ({len(generated)} files):")
        print(f"  {'─'*66}")
        for a in generated:
            dims = f"{a.get('width', '?')}x{a.get('height', '?')}" if 'width' in a else "?"
            size_kb = a['size_bytes'] / 1024
            print(f"    {a['path']:<45} {dims:>8}  {size_kb:>6.1f}KB")
    else:
        print("  No generated assets found.")
        print("  Run: python tools/ai/scripts/generate.py all")

    print(f"\n{'='*70}\n")


def print_manifest():
    if not MANIFEST_PATH.exists():
        print("No manifest found. Run export first.")
        return

    with open(MANIFEST_PATH) as f:
        manifest = json.load(f)

    print(f"\n{'='*70}")
    print(f"  EXPORT MANIFEST")
    print(f"{'='*70}\n")

    assets = manifest.get("assets", {})
    if not assets:
        print("  No exported assets in manifest.")
    else:
        for name, info in sorted(assets.items()):
            print(f"  {name}")
            print(f"    Source: {info.get('source', '?')}")
            print(f"    Target: {info.get('target', '?')}")
            print(f"    Exported: {info.get('exported_at', '?')}")
            print()

    print(f"{'='*70}\n")


def main():
    detailed = "--detailed" in sys.argv
    show_manifest = "--manifest" in sys.argv

    if show_manifest:
        print_manifest()
    else:
        generated = scan_generated(detailed)
        project = scan_project_assets(detailed)
        print_gallery(generated, project)


if __name__ == "__main__":
    main()
