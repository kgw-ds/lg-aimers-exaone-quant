#!/usr/bin/env bash
set -euo pipefail

MODEL_DIR="/home/gjustin1/lg_aimers/model"
EXP_DIR="/home/gjustin1/lg_aimers/experiments/E0"
LOG_DIR="$EXP_DIR/logs"
mkdir -p "$LOG_DIR"

# 포트(8000) 이미 쓰는 프로세스가 있으면 알려주고 종료
if ss -ltnp 2>/dev/null | grep -q ':8000'; then
  echo "[!] Port 8000 is already in use. Stop existing server first:"
  echo "    lsof -i :8000"
  echo "    kill -9 <PID>"
  exit 1
fi

echo "[*] Starting vLLM E0 server..."
# GPU 메모리 여유가 아슬아슬하면 0.88~0.85로 낮춰도 됨
GPU_UTIL=${GPU_UTIL:-0.88}

vllm serve "$MODEL_DIR" \
  --served-model-name "exaone-e0" \
  --port 8000 \
  --dtype float16 \
  --enforce-eager \
  --gpu-memory-utilization "$GPU_UTIL" \
  |& tee "$LOG_DIR/vllm_serve_e0_$(date -Iseconds | tr ':' '-').log"
