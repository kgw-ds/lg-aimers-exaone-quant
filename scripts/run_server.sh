#!/usr/bin/env bash
set -euo pipefail

EXP_DIR="${1:-}"
if [[ -z "$EXP_DIR" ]]; then
  echo "Usage: bash scripts/run_server.sh experiments/E0"
  exit 1
fi

CONFIG="$EXP_DIR/config.env"
if [[ ! -f "$CONFIG" ]]; then
  echo "Missing config: $CONFIG" 
  exit 1
fi

# load config
source "$CONFIG"

mkdir -p "$EXP_DIR/logs"

LOG_FILE="$EXP_DIR/logs/vllm_serve_${EXP_ID}.log"

echo "[*] Starting vLLM server for $EXP_ID"
echo " - MODEL_PATH: $MODEL_PATH"
echo " - SERVED_MODEL_NAME: $SERVED_MODEL_NAME"
echo " - PORT: $PORT"
echo " - LOG: $LOG_FILE"

# 예시 vLLM 실행 (너가 기존에 쓰던 옵션에 맞춰 조절 가능)
# NOTE: 이미 서버가 떠있으면 포트 충돌나니, 기존 프로세스 끄고 실행해야 함.
nohup python -m vllm.entrypoints.openai.api_server \
  --model "$MODEL_PATH" \
  --served-model-name "$SERVED_MODEL_NAME" \
  --host "$HOST" \
  --port "$PORT" \
  --gpu-memory-utilization "$GPU_UTILIZATION" \
  --max-model-len "$MAX_MODEL_LEN" \
  > "$LOG_FILE" 2>&1 &

echo "[✓] Server launched. Tail logs:"
echo "    tail -f $LOG_FILE"
