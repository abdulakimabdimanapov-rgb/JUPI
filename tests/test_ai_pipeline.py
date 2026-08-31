import json 
import os 
import sys
import tempfile
import unittest
from pathlib import Path

P

import json
import os
import sys
import tempfile
import unittest
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(PROJECT_ROOT / "tools" / "ai"))

from generators.comfyui_adapter import ComfyUIAdapter, FallbackGenerator
from validators.asset_validator import (
    validate_asset, check_png_signature, get_png_dimensions,
    has_transparency, load_config, ValidationResult
)
from exporters.asset_exporter import (
    export_asset, determine_target_dir, load_manifest
)


class TestPngSignature(unittest.TestCase):


    def test_valid_png_signature(self):

        png_path = PROJECT_ROOT / "assets" / "2d" / "characters" / "hunter.png"
        if png_path.exists():
            self.assertTrue(check_png_signature(png_path))

    def test_non_png_file(self):

        with tempfile.NamedTemporaryFile(suffix=".png", delete=False, mode="w") as f:
            f.write("not a png file")
            f.flush()
            try:
                self.assertFalse(check_png_signature(Path(f.name)))
            finally:
                os.unlink(f.name)

    def test_empty_file(self):

        with tempfile.NamedTemporaryFile(suffix=".png", delete=False) as f:
            f.flush()
            try:
                self.assertFalse(check_png_signature(Path(f.name)))
            finally:
                os.unlink(f.name)


class TestPngDimensions(unittest.TestCase):


    def test_read_dimensions(self):

        png_path = PROJECT_ROOT / "assets" / "2d" / "characters" / "hunter.png"
        if png_path.exists():
            dims = get_png_dimensions(png_path)
            self.assertIsNotNone(dims)
            self.assertEqual(dims[0], 16)
            self.assertEqual(dims[1], 16)

    def test_nonexistent_file(self):

        dims = get_png_dimensions(Path("/nonexistent/file.png"))
        self.assertIsNone(dims)


class TestAssetValidator(unittest.TestCase):


    def test_validate_existing_asset(self):

        png_path = PROJECT_ROOT / "assets" / "2d" / "characters" / "hunter.png"
        if png_path.exists():
            result = validate_asset(png_path)
            self.assertIsInstance(result, ValidationResult)
            self.assertTrue(result.checks.get("file_exists", False))
            self.assertTrue(result.checks.get("format_png", False))
            self.assertTrue(result.checks.get("valid_png", False))

    def test_validate_nonexistent(self):

        result = validate_asset(Path("/nonexistent/asset.png"))
        self.assertFalse(result.passed)
        self.assertFalse(result.checks.get("file_exists", True))

    def test_validation_score(self):

        png_path = PROJECT_ROOT / "assets" / "2d" / "characters" / "hunter.png"
        if png_path.exists():
            result = validate_asset(png_path)
            self.assertGreaterEqual(result.score, 0.0)
            self.assertLessEqual(result.score, 1.0)

    def test_validation_report(self):

        png_path = PROJECT_ROOT / "assets" / "2d" / "characters" / "hunter.png"
        if png_path.exists():
            result = validate_asset(png_path)
            report = result.report()
            self.assertIsInstance(report, str)
            self.assertIn("hunter.png", report)


class TestTransparency(unittest.TestCase):


    def test_sprite_has_transparency(self):

        png_path = PROJECT_ROOT / "assets" / "2d" / "characters" / "hunter.png"
        if png_path.exists():
            result = has_transparency(png_path)
            self.assertIsInstance(result, bool)


class TestFallbackGenerator(unittest.TestCase):


    def test_generate_placeholder(self):

        with tempfile.TemporaryDirectory() as tmpdir:
            gen = FallbackGenerator(Path(tmpdir))
            result = gen.generate_character_placeholder("test_char")
            self.assertIsNotNone(result)
            self.assertTrue(Path(result).exists())
            self.assertTrue(check_png_signature(Path(result)))

    def test_placeholder_dimensions(self):

        with tempfile.TemporaryDirectory() as tmpdir:
            gen = FallbackGenerator(Path(tmpdir))
            result = gen.generate_character_placeholder("test_char")
            if result:
                dims = get_png_dimensions(Path(result))
                self.assertEqual(dims, (16, 16))


class TestAssetExporter(unittest.TestCase):


    def test_determine_target_dir(self):

        config = load_config()
        self.assertIn("characters", determine_target_dir("character_hunter.png", config))
        self.assertIn("enemies", determine_target_dir("enemy_guard.png", config))
        self.assertIn("tiles", determine_target_dir("tile_asphalt.png", config))
        self.assertIn("hud", determine_target_dir("hp_bar.png", config))

    def test_export_dry_run(self):

        with tempfile.TemporaryDirectory() as tmpdir:
            src = Path(tmpdir) / "test_asset.png"
            src.write_bytes(b"\x89PNG\r\n\x1a\n" + b"\x00" * 100)

            config = load_config()
            result = export_asset(src, config, dry_run=True)
            self.assertTrue(result["success"])
            self.assertEqual(result["action"], "would_export")


class TestComfyUIAdapter(unittest.TestCase):


    def test_not_available_by_default(self):

        adapter = ComfyUIAdapter()
        result = adapter.is_available()
        self.assertIsInstance(result, bool)

    def test_load_workflow(self):

        adapter = ComfyUIAdapter()
        wf = adapter.load_workflow("pixel_art_16x16")
        self.assertIsNotNone(wf)
        self.assertIn("nodes", wf)


class TestConfig(unittest.TestCase):


    def test_load_config(self):

        config = load_config()
        self.assertIsInstance(config, dict)
        self.assertIn("pixel_art", config)
        self.assertIn("comfyui", config)

    def test_pixel_art_config(self):

        config = load_config()
        pa = config.get("pixel_art", {})
        self.assertEqual(pa.get("tile_size"), 16)
        self.assertEqual(pa.get("sheet_columns"), 8)
        self.assertEqual(pa.get("texture_filter"), "nearest")


class TestManifest(unittest.TestCase):


    def test_load_manifest(self):

        manifest = load_manifest()
        self.assertIsInstance(manifest, dict)
        self.assertIn("assets", manifest)


class TestAllProjectAssets(unittest.TestCase):


    def test_all_project_pngs(self):

        assets_dir = PROJECT_ROOT / "assets" / "2d"
        if not assets_dir.exists():
            self.skipTest("assets/2d not found")

        failures = []
        for png in assets_dir.rglob("*.png"):
            result = validate_asset(png)
            if not result.passed:
                failures.append(f"{png.name}: {[k for k,v in result.checks.items() if not v]}")

        if failures:
            self.fail(f"Asset validation failures:\n" + "\n".join(failures))


if __name__ == "__main__":
    unittest.main(verbosity=2)
                             