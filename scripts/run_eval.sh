#!/usr/bin/env bash
PY="${PY:-}"; 
if [ -z "$PY" ]; then 
  if [ -x "$PWD/venv/bin/python" ]; then PY="$PWD/venv/bin/python"; 
  elif [ -x "$HOME/lg_aimers/venv/bin/python" ]; then PY="$HOME/lg_aimers/venv/bin/python"; 
  else PY="$(command -v python3)"; fi; 
fi

set -euo pipefail

EXP_DIR="${1:-}"
MODE="${2:-all}"   # all | gsm8k | ppl
if [[ -z "$EXP_DIR" ]]; then
  echo "Usage: bash scripts/run_eval.sh experiments/E0 [all|gsm8k|ppl]"
  exit 1
fi

CONFIG="$EXP_DIR/config.env"
if [[ ! -f "$CONFIG" ]]; then
  echo "Missing config: $CONFIG" 
  exit 1
fi

source "$CONFIG"

mkdir -p "$EXP_DIR/evals"

echo "[*] Quick health check..."
curl -s "http://localhost:${PORT}/v1/models" | head -c 200; echo
echo

run_gsm8k () {
  local ts
  ts="$(date -Iseconds | tr ':' '-')"
  local out="$EXP_DIR/evals/gsm8k_full_${ts}.json"

  echo "[*] (A) GSM8K FULL eval starting..."
  $PY -m lm_eval \
    --model local-chat-completions \
    --tasks "$GSM8K_TASK" \
    --apply_chat_template \
    --model_args model="$SERVED_MODEL_NAME",base_url="$BASE_URL",num_concurrent="$NUM_CONCURRENT",max_retries="$MAX_RETRIES",eos_string="$EOS_STRING" \
    --gen_kwargs "temperature=0,do_sample=False" \
    --output_path "$out"

  echo "[✓] GSM8K saved: $out"
}

run_ppl () {
  local ts
  ts="$(date -Iseconds | tr ':' '-')"
  local out="$EXP_DIR/evals/wikitext2_ppl_${ts}.json"

  echo "[*] (B) PPL baseline on wikitext2 starting..."
  # loglikelihood_rolling은 chat-completions에 취약할 때가 있어서
  # completions + local tokenizer 백엔드를 쓰는 쪽이 안정적인 경우가 많음.
  # base_url은 /v1/completions 로 바꿔줌.
  local completions_url
  completions_url="$(echo "$BASE_URL" | sed 's#/v1/chat/completions#/v1/completions#')"

  # tokenizer 경로는 반드시 절대경로로! (~는 transformers가 repo_id로 오해할 수 있음)
  local tok_path
  tok_path="$($PY - <<PY
import os
print(os.path.expanduser("$MODEL_PATH"))
PY
)"

  $PY -m lm_eval \
    --model local-completions \
    --tasks "$WIKITEXT_TASK" \
    --model_args model="$SERVED_MODEL_NAME",base_url="$completions_url",num_concurrent="$NUM_CONCURRENT",max_retries="$MAX_RETRIES",tokenizer="$tok_path" \
    --output_path "$out"

  echo "[✓] Wikitext PPL saved: $out"
}

case "$MODE" in
  all)   run_gsm8k; run_ppl ;;
  gsm8k) run_gsm8k ;;
  ppl)   run_ppl ;;
  *)
    echo "Unknown mode: $MODE"
    exit 1
    ;;
esac
