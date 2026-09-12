#!/bin/bash
set -e

OPTIONS_FILE="/data/options.json"
if [ -f "$OPTIONS_FILE" ]; then
    WORKERS=$(jq -r '.kokoro_workers // 2' "$OPTIONS_FILE")
    SPEED=$(jq -r '.speed // 1.125' "$OPTIONS_FILE")
else
    WORKERS=2
    SPEED=1.125
fi

export KOKORO_WORKERS="$WORKERS"
export KOKORO_ONNX_SPEED="$SPEED"
export KOKORO_ONNX_MODEL="/data/kokoro-models/kokoro-martin.onnx"
export KOKORO_ONNX_VOICES="/data/kokoro-models/voices-martin.npz"

MODEL_DIR="/data/kokoro-models"
mkdir -p "$MODEL_DIR"

if [ ! -f "$MODEL_DIR/kokoro-martin.onnx" ] || [ $(stat -c%s "$MODEL_DIR/kokoro-martin.onnx" 2>/dev/null || echo 0) -lt 100000000 ]; then
    echo "[Kokoro] Downloading kokoro-martin.onnx (~325 MB) from Hugging Face..."
    curl -L --fail -o "$MODEL_DIR/kokoro-martin.onnx" "https://huggingface.co/Godelaune/Kokoro-82M-ONNX-German-Martin/resolve/main/kokoro-martin.onnx"
    echo "[Kokoro] Model download complete."
fi

if [ ! -f "$MODEL_DIR/voices-martin.npz" ] || [ $(stat -c%s "$MODEL_DIR/voices-martin.npz" 2>/dev/null || echo 0) -lt 100000 ]; then
    echo "[Kokoro] Downloading voices-martin.npz from Hugging Face..."
    curl -L --fail -o "$MODEL_DIR/voices-martin.npz" "https://huggingface.co/Godelaune/Kokoro-82M-ONNX-German-Martin/resolve/main/voices-martin.npz"
    echo "[Kokoro] Voices download complete."
fi

# Cleanup on exit
trap 'kill $FASTAPI_PID $WYOMING_PID 2>/dev/null' EXIT INT TERM

echo "[Kokoro] Starting FastAPI service with $WORKERS workers (speed $SPEED)..."
cd /app
python3 -m uvicorn main:app --host 127.0.0.1 --port 8881 &
FASTAPI_PID=$!

echo "[Kokoro] Waiting for FastAPI to initialize..."
for i in {1..30}; do
    if curl -s http://127.0.0.1:8881/v1/audio/voices >/dev/null 2>&1; then
        echo "[Kokoro] FastAPI is up and healthy."
        break
    fi
    sleep 1
done

echo "[Kokoro] Starting Wyoming OpenAI Bridge on port 10203 (language: de, voice: martin)..."
python3 -m wyoming_openai \
    --uri tcp://0.0.0.0:10203 \
    --languages de \
    --tts-openai-url http://127.0.0.1:8881/v1 \
    --tts-models kokoro \
    --tts-streaming-models kokoro \
    --tts-voices martin \
    --tts-backend KOKORO_FASTAPI &
WYOMING_PID=$!

wait $WYOMING_PID
