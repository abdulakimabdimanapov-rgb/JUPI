

import sys
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent.parent
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from validators.asset_validator import (
    validate_asset, validate_directory, print_summary, load_config
)

GENERATED_DIR = Path(__file__).resolve().parent.parent / "generated"


def main():
    strict = "--strict" in sys.argv
    validate_all_project = "--all" in sys.argv
    paths = [Path(p) for p in sys.argv[1:] if not p.startswith("--")]

    config = load_config()
    if strict:
        config.setdefault("validation", {})["strict_mode"] = True

    results = []

    if not paths:
        print(f"Validating all assets in {GENERATED_DIR}...")
        results = validate_directory(GENERATED_DIR, config)
    elif validate_all_project:
        print("Validating all PNGs in project...")
        for png_dir in ["assets/2d", "tools/ai/generated"]:
            d = PROJECT_ROOT / png_dir
            if d.exists():
                results.extend(validate_directory(d, config))
    else:
        for p in paths:
            if p.is_file():
                results.append(validate_asset(p, config))
            elif p.is_dir():
                results.extend(validate_directory(p, config))

    if results:
        print_summary(results)
        sys.exit(0 if all(r.passed for r in results) else 1)
    else:
        print("No assets found to validate.")
        sys.exit(0)


if __name__ == "__main__":
    main()
