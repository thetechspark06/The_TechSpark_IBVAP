"""
IBVAP - One-Command Master Launcher
Initializes the environment, verifies models and showcase media,
starts the FastAPI backend & AI inference pipeline, and launches the web dashboard.
"""

import os
import signal
import sys
import time
import webbrowser
from pathlib import Path
import torch

def handle_exit(signum, frame):
    print("\n[IBVAP] Received exit signal (Ctrl+C). Terminating immediately...")
    os._exit(0)

signal.signal(signal.SIGINT, handle_exit)
if hasattr(signal, "SIGBREAK"):
    signal.signal(signal.SIGBREAK, handle_exit)

BASE_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(BASE_DIR))

from backend.config import load_config
from backend.logger import logger
from database.database import DatabaseManager


def print_banner():
    banner = """
======================================================================
     IBVAP — INTELLIGENT BORDER & VIDEO ANALYTICS PLATFORM
======================================================================
    CCTV Source -> YOLO Detection -> ByteTrack -> ANPR/OCR
         -> Face Detection -> Virtual Fence -> Dashboard
======================================================================
    """
    print(banner)


def check_environment():
    """Validates Python, PyTorch, and CUDA GPU status."""
    print("[1/5] Checking Environment & Acceleration...")
    py_ver = f"{sys.version_info.major}.{sys.version_info.minor}.{sys.version_info.micro}"
    print(f"      Python Version: {py_ver}")

    has_cuda = torch.cuda.is_available()
    if has_cuda:
        gpu_name = torch.cuda.get_device_name(0)
        print(f"      [OK] NVIDIA GPU Detected: {gpu_name} (CUDA Enabled)")
    else:
        print("      [INFO] CUDA Unavailable -> Running on CPU (Optimized)")


def check_models(config):
    """Verifies model files according to custom weights guidelines."""
    print("\n[2/5] Inspecting AI Models...")
    models_to_check = [
        ("General Detector", config.models.general),
        ("Custom Vehicle Model", config.models.vehicle),
        ("License Plate Detector", config.models.plate),
        ("Face Detector Model", config.models.face),
    ]

    for label, rel_path in models_to_check:
        p = BASE_DIR / rel_path
        if p.exists():
            print(f"      [OK] {label}: Found at {rel_path}")
        else:
            print(f"      [WARNING] {p.name} not found. Place the model inside models/.")


def check_video():
    """Ensures showcase video exists or auto-generates demonstration media."""
    print("\n[3/5] Verifying Demonstration Video Media...")
    video_path = BASE_DIR / "videos" / "showcase.mp4"
    if not video_path.exists():
        print("      [INFO] showcase.mp4 not found. Synthesizing showcase video...")
        try:
            from videos.generate_showcase_video import generate_video
            generate_video(num_seconds=15, fps=30)
            print("      [OK] Showcase video synthesized successfully.")
        except Exception as e:
            print(f"      [ERROR] Could not generate showcase video: {e}")
    else:
        print(f"      [OK] Showcase video found at {video_path}")


def init_database(config):
    """Initializes SQLite database and tables."""
    print("\n[4/5] Initializing Database...")
    db = DatabaseManager(config)
    db.init_db()
    print(f"      [OK] Database initialized at {config.database.path}")


def start_server(config):
    """Starts FastAPI backend and opens dashboard."""
    print("\n[5/5] Launching IBVAP Backend & Web Dashboard...")
    host = config.application.web_host
    port = config.application.web_port
    url = f"http://localhost:{port}"

    print(f"\n>>> IBVAP DASHBOARD URL: {url}")
    print(f">>> API DOCUMENTATION:  {url}/docs")
    print(f">>> LIVE CCTV FEED:     {url}/api/video_feed/CAM_01\n")
    print("Press Ctrl+C to terminate application gracefully.\n")

    # Automatically open browser after 1.5 seconds
    def open_browser():
        time.sleep(1.5)
        try:
            webbrowser.open(url)
        except Exception:
            pass

    import threading
    threading.Thread(target=open_browser, daemon=True).start()

    try:
        import uvicorn
        uvicorn.run("backend.main:app", host=host, port=port, log_level="info")
    except (KeyboardInterrupt, SystemExit):
        print("\n[IBVAP] Server stopped.")
        os._exit(0)


def main():
    print_banner()
    config = load_config()
    check_environment()
    check_models(config)
    check_video()
    init_database(config)
    start_server(config)


if __name__ == "__main__":
    main()
