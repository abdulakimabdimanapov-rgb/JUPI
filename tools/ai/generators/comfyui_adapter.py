

import json
import os
import time
import uuid
import urllib.request
import urllib.error
from pathlib import Path
from typing import Optional, Dict, Any

PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent.parent
CONFIG_PATH = Path(__file__).resolve().parent.parent / "config" / "pipeline_config.json"


class ComfyUIAdapter:


    def __init__(self, config: dict = None):
        if config is None:
            config = self._load_config()
        comfy_cfg = config.get("comfyui", {})
        self.enabled = comfy_cfg.get("enabled", False)
        self.host = comfy_cfg.get("host", "127.0.0.1")
        self.port = comfy_cfg.get("port", 8188)
        self.timeout = comfy_cfg.get("timeout_seconds", 120)
        self.poll_interval = comfy_cfg.get("poll_interval_ms", 500) / 1000.0
        self.output_dir = Path(PROJECT_ROOT) / comfy_cfg.get("output_dir", "tools/ai/generated")
        self.base_url = f"http://{self.host}:{self.port}"
        self.client_id = str(uuid.uuid4())
        self._connected = False

    def _load_config(self) -> dict:
        if CONFIG_PATH.exists():
            with open(CONFIG_PATH) as f:
                return json.load(f)
        return {}

    def is_available(self) -> bool:

        if not self.enabled:
            return False
        try:
            req = urllib.request.urlopen(f"{self.base_url}/system_stats", timeout=3)
            req.read()
            self._connected = True
            return True
        except Exception:
            self._connected = False
            return False

    def get_system_stats(self) -> Optional[dict]:

        try:
            req = urllib.request.urlopen(f"{self.base_url}/system_stats", timeout=5)
            return json.loads(req.read())
        except Exception:
            return None

    def list_models(self) -> Dict[str, list]:

        try:
            req = urllib.request.urlopen(f"{self.base_url}/object_info", timeout=5)
            info = json.loads(req.read())
            models = {}
            for key in ["CheckpointLoaderSimple", "LoraLoader"]:
                if key in info:
                    models[key] = info[key].get("input", {}).get("required", {})
            return models
        except Exception:
            return {}

    def load_workflow(self, workflow_name: str) -> Optional[dict]:

        workflow_path = Path(__file__).resolve().parent.parent / "workflows" / f"{workflow_name}.json"
        if not workflow_path.exists():
            print(f"Workflow not found: {workflow_path}")
            return None
        with open(workflow_path) as f:
            return json.load(f)

    def generate(self, prompt: str, workflow: str = "pixel_art_16x16",
                 seed: int = None, params: dict = None) -> Optional[Dict[str, Any]]:

        if not self.is_available():
            return {
                "success": False,
                "error": "ComfyUI is not running or not enabled. "
                         "Start ComfyUI with: python main.py --listen"
            }

        wf = self.load_workflow(workflow)
        if wf is None:
            return {"success": False, "error": f"Workflow '{workflow}' not found"}

        if seed is None:
            seed = int.from_bytes(os.urandom(4), "big")

        wf_str = json.dumps(wf)
        wf_str = wf_str.replace("{prompt}", prompt)
        wf_str = wf_str.replace("{seed}", str(seed))
        if params:
            for key, value in params.items():
                wf_str = wf_str.replace(f"{{{key}}}", str(value))
        wf = json.loads(wf_str)

        nodes = wf.get("nodes", {})
        api_payload = {
            "prompt": nodes,
            "client_id": self.client_id
        }

        try:
            data = json.dumps(api_payload).encode("utf-8")
            req = urllib.request.Request(
                f"{self.base_url}/prompt",
                data=data,
                headers={"Content-Type": "application/json"}
            )
            resp = urllib.request.urlopen(req, timeout=10)
            result = json.loads(resp.read())
            prompt_id = result.get("prompt_id")
        except Exception as e:
            return {"success": False, "error": f"Failed to submit workflow: {e}"}

        if not prompt_id:
            return {"success": False, "error": "No prompt_id returned from ComfyUI"}

        start_time = time.time()
        while time.time() - start_time < self.timeout:
            try:
                req = urllib.request.urlopen(f"{self.base_url}/history/{prompt_id}", timeout=5)
                history = json.loads(req.read())
                if prompt_id in history:
                    outputs = history[prompt_id].get("outputs", {})
                    for node_id, node_output in outputs.items():
                        images = node_output.get("images", [])
                        if images:
                            img_info = images[0]
                            filename = img_info.get("filename", "")
                            subfolder = img_info.get("subfolder", "")
                            img_url = f"{self.base_url}/view?filename={filename}&subfolder={subfolder}&type=output"
                            output_path = self.output_dir / filename
                            output_path.parent.mkdir(parents=True, exist_ok=True)
                            urllib.request.urlretrieve(img_url, str(output_path))
                            return {
                                "success": True,
                                "output_path": str(output_path),
                                "seed": seed,
                                "workflow": workflow,
                                "prompt": prompt
                            }
            except Exception:
                pass
            time.sleep(self.poll_interval)

        return {"success": False, "error": f"Generation timed out after {self.timeout}s"}

    def queue_prompt(self, workflow_name: str, prompt: str, **kwargs) -> Optional[str]:

        result = self.generate(prompt, workflow_name, **kwargs)
        if result and result.get("success"):
            return result.get("output_path")
        return None


class FallbackGenerator:


    def __init__(self, output_dir: Path = None):
        self.output_dir = output_dir or Path(__file__).resolve().parent.parent / "generated"

    def generate_placeholder(self, name: str, width: int = 16, height: int = 16,
                            color: tuple = (100, 100, 120)) -> Optional[str]:

        output_path = self.output_dir / f"{name}.png"
        output_path.parent.mkdir(parents=True, exist_ok=True)

        try:
            import zlib
            import struct

            def make_png(w, h, rgb):
                def chunk(chunk_type, data):
                    c = chunk_type + data
                    return struct.pack(">I", len(data)) + c + struct.pack(">I", zlib.crc32(c) & 0xFFFFFFFF)

                header = b"\x89PNG\r\n\x1a\n"
                ihdr = chunk(b"IHDR", struct.pack(">IIBBBBB", w, h, 8, 2, 0, 0, 0))

                raw = b""
                for y in range(h):
                    raw += b"\x00"
                    for x in range(w):
                        raw += bytes(rgb)

                idat = chunk(b"IDAT", zlib.compress(raw))
                iend = chunk(b"IEND", b"")
                return header + ihdr + idat + iend

            png_data = make_png(width, height, color)
            with open(output_path, "wb") as f:
                f.write(png_data)
            return str(output_path)
        except Exception as e:
            print(f"Fallback generation failed: {e}")
            return None

    def generate_character_placeholder(self, name: str) -> Optional[str]:

        colors = {
            "hunter": (70, 50, 90),
            "guard": (80, 70, 60),
            "fast": (50, 75, 50),
            "heavy": (90, 80, 70),
            "npc": (80, 90, 100),
            "mouse": (160, 155, 145),
            "rat": (115, 95, 80),
            "cat": (190, 130, 65),
        }
        color = colors.get(name.lower(), (100, 100, 120))
        return self.generate_placeholder(f"character_{name}", 16, 16, color)


if __name__ == "__main__":
    adapter = ComfyUIAdapter()
    if adapter.is_available():
        print("✓ ComfyUI is running and reachable")
        stats = adapter.get_system_stats()
        if stats:
            print(f"  System: {json.dumps(stats, indent=2)}")
    else:
        print("✗ ComfyUI is not available")
        print("  Start ComfyUI with: cd /path/to/ComfyUI && python main.py --listen")
        print("  Falling back to procedural generation")

        gen = FallbackGenerator()
        result = gen.generate_character_placeholder("hunter")
        if result:
            print(f"  Generated placeholder: {result}")
