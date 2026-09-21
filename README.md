# IBVAP — Intelligent Border / Video Analytics Platform

[![Python](https://img.shields.io/badge/Python-3.11%20%7C%203.12%20%7C%203.13-blue.svg)](https://www.python.org/)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.100+-009688.svg)](https://fastapi.tiangolo.com/)
[![YOLO](https://img.shields.io/badge/YOLO-Ultralytics%20YOLO11-00FFFF.svg)](https://github.com/ultralytics/ultralytics)
[![Tracking](https://img.shields.io/badge/Tracking-ByteTrack%20%2F%20BoTSORT-orange.svg)](https://github.com/ifzhang/ByteTrack)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

**IBVAP** is an enterprise-grade AI video analytics and surveillance prototype engineered for CCTV border security, perimeter defense, and automated traffic surveillance. It processes feeds from recorded MP4 videos, webcams, and RTSP IP cameras, performing multi-object detection, ByteTrack tracking, license plate OCR (ANPR), face detection, and virtual security boundary monitoring with real-time web dashboard telemetry.

---

## 🌟 Key Features

1. **Person & Vehicle Detection**: YOLO11 / custom `.pt` model inference with CUDA GPU acceleration and automatic CPU fallback.
2. **Persistent Multi-Object Tracking**: Integrates **ByteTrack** and **BoT-SORT** with persistent ID persistence and motion path trajectory tracking.
3. **License Plate Recognition (ANPR)**: Automatic vehicle bumper/ROI extraction, image preprocessing (CLAHE, bilateral filtering, sharpening, adaptive thresholding, deskew), and PaddleOCR character extraction with format validation (`MH15AB1234`).
4. **Face Detection & Recognition**: Detects facial regions from stream and person bounding boxes with local database matching.
5. **Virtual Fence & Perimeter Breach**: Configurable line-crossing, rectangular, and polygon zones with directional vector crossing math and alert cooldown deduplication.
6. **Central Event Engine & Snapshots**: Standard event schema (`PERSON_DETECTED`, `VEHICLE_DETECTED`, `FACE_DETECTED`, `ANPR`, `FENCE_VIOLATION`), saving high-contrast annotated snapshots to `output/snapshots/` and logging to `output/events.json`.
7. **FastAPI & Real-Time Telemetry**: High-performance REST API, WebSocket event broadcasting, and live MJPEG streaming (`/api/video_feed/CAM_01`).
8. **Surveillance Web Dashboard**: High-contrast dark CCTV command center with live video canvas, interactive fence setup, real-time KPI counters, audio alerts, and Chart.js analytics.
9. **Showcase Demo Mode**: Complete offline evaluation mode running on `videos/showcase.mp4`.

---

## 🏗️ Architecture

```
                          CCTV Video Streams
                   (Showcase MP4 / Webcam / RTSP)
                                 │
                                 ▼
                     Video Ingestion & Worker
                                 │
     ┌───────────────────┬───────┴───────────┬───────────────────┐
     ▼                   ▼                   ▼                   ▼
Person & Vehicle    ByteTrack /         License Plate       Face Detection
YOLO Detection     Motion Path            ANPR / OCR         (YOLO / ROI)
     │                   │                   │                   │
     └───────────────────┴───────┬───────────┴───────────────────┘
                                 │
                                 ▼
                   Virtual Fence / Security Zone
                    (Line, Rect, Polygon Math)
                                 │
                                 ▼
                       Central Event Engine
             (Deduplication, Cooldown, Schema Validation)
                     │                         │
                     ▼                         ▼
         Database & File Storage        FastAPI Backend
       - SQLite / PostgreSQL         - REST API (/api/health)
       - output/snapshots/*.jpg       - WebSocket (/ws/events)
       - output/events.json           - MJPEG Stream (/api/video_feed)
                                               │
                                               ▼
                                      Surveillance Dashboard
                                     (React / Standalone Web)
```

---

## 📋 Directory Structure

```
IBVAP/
│
├── backend/
│   ├── main.py                  # FastAPI server entry point & lifespan
│   ├── config.py                # Configuration loader & Pydantic models
│   ├── logger.py                # Centralized thread-safe logger
│   ├── api/
│   │   └── routes.py            # REST API endpoints & MJPEG generator
│   ├── services/
│   │   └── video_pipeline.py    # Core video capture, AI loop, & annotation
│   ├── websocket/
│   │   └── manager.py           # Real-time WebSocket connection manager
│   └── static/
│       └── index.html           # Full-featured surveillance web dashboard
│
├── ai/
│   ├── detection.py             # YOLO11 Person & Vehicle detection
│   ├── tracking.py              # ByteTrack / BoT-SORT multi-object tracker
│   ├── plate_detection.py       # License plate detector & ROI extractor
│   ├── ocr.py                   # Plate image preprocessing & OCR
│   ├── face_detection.py        # Face detection & local recognition
│   ├── virtual_fence.py         # Virtual boundary crossing & zone logic
│   └── event_engine.py          # Central event broker & snapshot saver
│
├── database/
│   ├── database.py              # SQLAlchemy engine & session management
│   ├── models.py                # ORM Models (Events, Plates, Alerts, Cameras)
│   └── repository.py            # Data access layer & analytics queries
│
├── dashboard/                   # React + Vite + TypeScript frontend project
│   ├── src/
│   │   ├── App.tsx
│   │   └── main.tsx
│   ├── package.json
│   └── vite.config.ts
│
├── models/
│   ├── yolo11n.pt               # General YOLO detection weights
│   ├── vehicle_model.pt         # Optional custom vehicle weights
│   ├── license_plate_detector.pt# Optional custom license plate weights
│   └── face_model.pt            # Optional custom face detector weights
│
├── videos/
│   ├── showcase.mp4             # Demonstration CCTV video
│   └── generate_showcase_video.py # Synthetic demo video generator
│
├── output/
│   ├── snapshots/               # Event snapshot captures (.jpg)
│   ├── events.json              # Historical event log
│   └── showcase_output.mp4      # Recorded annotated showcase video
│
├── data/
│   └── ibvap.db                 # SQLite surveillance database
│
├── logs/
│   └── ibvap.log                # System runtime log
│
├── tests/                       # Automated pytest suite
│   ├── test_config.py
│   ├── test_database.py
│   ├── test_ai_pipeline.py
│   ├── test_event_engine.py
│   └── test_api.py
│
├── config.yaml                  # Main YAML configuration file
├── requirements.txt             # Python dependencies
├── .env.example                 # Environment variable template
├── .env                         # Local runtime environment file
├── Dockerfile                   # Production Docker container definition
├── docker-compose.yml           # Docker compose orchestrator
├── run.py                       # One-command system master launcher
├── start_demo.bat               # Windows launcher script
├── start_backend.bat            # Windows backend startup script
└── start_dashboard.bat          # Windows dashboard browser opener
```

---

## 🚀 Quick Start & Installation

### Step 1: Install Python
Ensure Python 3.11, 3.12, or 3.13 is installed on your Windows PC or Linux server.

### Step 2: Create a Virtual Environment
```bash
python -m venv venv
# On Windows:
.\venv\Scripts\activate
# On Linux/macOS:
source venv/bin/activate
```

### Step 3: Install Dependencies
```bash
pip install -r requirements.txt
```

### Step 4: Place Custom `.pt` Models (Optional)
Place your trained weights in `models/`:
- `models/yolo11n.pt` (General YOLO model — included)
- `models/vehicle_model.pt` (Custom vehicle model)
- `models/license_plate_detector.pt` (Custom license plate detector)
- `models/face_model.pt` (Custom face detector)

> **Note on Custom Weights**: In strict accordance with the project specification, if custom `.pt` files are absent, the system displays an explicit warning and gracefully executes fallback detection without crashing or downloading unrelated weights.

### Step 5: Verify Demo Video Media
A 15-second multi-actor showcase CCTV video is pre-generated at `videos/showcase.mp4`. To regenerate or customize it:
```bash
python videos/generate_showcase_video.py
```

### Step 6: Configure `config.yaml`
Customize camera sources, virtual fence coordinates, and thresholds in `config.yaml`:
```yaml
video:
  source: videos/showcase.mp4   # Or 0 for Webcam, or rtsp://...
  output: output/showcase_output.mp4

virtual_fence:
  enabled: true
  type: line                    # line, rect, or polygon
  points:
    - [100, 400]
    - [1100, 400]
  cooldown_seconds: 8
```

---

## ⚡ Running the System

### Option A: One-Command Launcher (Recommended)
```bash
python run.py
```
Or on Windows:
```cmd
start_demo.bat
```
This automatically:
1. Validates Python and CUDA GPU acceleration.
2. Inspects models in `models/`.
3. Verifies `videos/showcase.mp4`.
4. Initializes `data/ibvap.db`.
5. Starts the FastAPI backend and AI processing engine.
6. Launches your web browser to `http://localhost:8000`.

### Option B: Individual Batch Launchers (Windows)
- **Start Backend**: `start_backend.bat`
- **Open Dashboard**: `start_dashboard.bat`

---

## 🐳 Docker Deployment

To deploy in containerized environments with NVIDIA GPU support:
```bash
docker-compose up --build
```

Access the dashboard at `http://localhost:8000`.

---

## 🧪 Running Automated Tests

Execute the complete pytest verification suite covering AI detection, tracking, virtual fence geometry, ANPR preprocessing, database transactions, and FastAPI REST endpoints:

```bash
python -m pytest tests/ -v
```

---

## 📡 REST API Reference

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/api/health` | System status, GPU/CPU info, FPS, and inference latency |
| `GET` | `/api/cameras` | List configured CCTV cameras |
| `POST` | `/api/cameras` | Register a new webcam or RTSP camera |
| `GET` | `/api/events` | Query stored security events with pagination & filters |
| `GET` | `/api/events/recent` | Get latest event cache for real-time dashboard tickers |
| `GET` | `/api/statistics` | Aggregate counts for vehicles, persons, faces, plates, and alerts |
| `GET` | `/api/plates` | Query license plate recognition log |
| `GET` | `/api/alerts` | Query active security alerts & fence violations |
| `POST` | `/api/alerts/{id}/acknowledge` | Acknowledge a perimeter breach alert |
| `GET` | `/api/config` | Retrieve current system configuration |
| `POST` | `/api/config` | Update virtual fence coordinates dynamically |
| `GET` | `/api/video_feed/{camera_id}` | Live multipart MJPEG video stream with AI overlays |
| `WS` | `/ws/events` | Real-time WebSocket connection for live event streaming |

---

## 🏆 Judge Demonstration Checklist

- [x] **Application Starts**: One-command launch via `python run.py`.
- [x] **Hardware Acceleration**: Automatic detection of NVIDIA GPU / CPU with telemetry HUD.
- [x] **Model Loading**: Modular `.pt` loading with graceful fallback.
- [x] **Person & Vehicle Detection**: YOLO11 bounding boxes and classification.
- [x] **Multi-Object Tracking**: ByteTrack persistent tracking IDs (`Person #1`, `Car #7`).
- [x] **Virtual Fence Violation**: Crossing detection triggers `🚨 VIRTUAL FENCE VIOLATION`.
- [x] **License Plate OCR (ANPR)**: Automatic plate extraction, image preprocessing, and text parsing.
- [x] **Face Detection**: Head/face localization and optional local database matching.
- [x] **Event Engine & Snapshots**: Automated image capture stored in `output/snapshots/`.
- [x] **Live Web Dashboard**: Interactive CCTV control room with live MJPEG feed, stats, sound alerts, and charts.
