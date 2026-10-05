#!/bin/bash
set -e

echo "[start.sh] Launching ComfyUI in background..."
cd /comfyui
python main.py --listen 0.0.0.0 --port 8188 &
COMFY_PID=$!

echo "[start.sh] Waiting for ComfyUI to become ready on port 8188..."
for i in $(seq 1 60); do
    if curl -s http://127.0.0.1:8188/ > /dev/null 2>&1; then
        echo "[start.sh] ComfyUI is up (after ${i}s)."
        break
    fi
    sleep 2
done

echo "[start.sh] Starting RunPod handler..."
exec python -u /comfyui/handler.py
