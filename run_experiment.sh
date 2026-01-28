#!/usr/bin/env bash
set -euo pipefail

EXP_ID="${1:-}"
ACTION="${2:-}"

if [[ -z "$EXP_ID" || -z "$ACTION" ]]; then
  echo "Usage: ./run_experiment.sh <E0|E1|...> <server|eval|gsm8k|ppl|all>"
  exit 1
fi

EXP_DIR="experiments/${EXP_ID}"

if [[ ! -d "$EXP_DIR" ]]; then
  echo "No such experiment dir: $EXP_DIR" 
  exit 1
fi

case "$ACTION" in
  server)
    bash scripts/run_server.sh "$EXP_DIR"
    ;;
  eval|all)
    bash scripts/run_eval.sh "$EXP_DIR" all
    ;;
  gsm8k)
    bash scripts/run_eval.sh "$EXP_DIR" gsm8k
    ;;
  ppl)
    bash scripts/run_eval.sh "$EXP_DIR" ppl
    ;;
  *)
    echo "Unknown action: $ACTION"
    exit 1
    ;;
esac
