#!/usr/bin/env bash
set -euo pipefail

EXP_DIR="/home/gjustin1/lg_aimers/experiments/E0"
EVAL_DIR="$EXP_DIR/evals"
mkdir -p "$EVAL_DIR"

BASE_URL="http://localhost:8000/v1/chat/completions"
MODEL="exaone-e0"

STAMP="$(date -Iseconds | tr ':' '-')"

echo "[*] Quick health check..."
curl -s http://localhost:8000/v1/models | head -c 200; echo

echo "[*] (A) GSM8K FULL eval starting..."
python -m lm_eval \
  --model local-chat-completions \
  --tasks gsm8k \
  --apply_chat_template \
  --model_args model=${MODEL},base_url=${BASE_URL},num_concurrent=1,max_retries=3,eos_string="[|endofturn|]" \
  --gen_kwargs "temperature=0,do_sample=False" \
  --output_path "${EVAL_DIR}/gsm8k_full_${STAMP}.json"

echo "[*] (B) PPL baseline on wikitext2 starting..."
# wikitext PPL은 로딩/계산이 꽤 걸릴 수 있음
python -m lm_eval \
  --model local-chat-completions \
  --tasks wikitext \
  --apply_chat_template \
  --model_args model=${MODEL},base_url=${BASE_URL},num_concurrent=1,max_retries=3,eos_string="[|endofturn|]" \
  --output_path "${EVAL_DIR}/ppl_wikitext_${STAMP}.json"

echo "[*] Done. Latest outputs:"
ls -t "${EVAL_DIR}"/*.json | head
