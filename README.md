# LG Aimers EXAONE Quantization Experiments

Reproducible pipeline for:
- serving EXAONE locally via vLLM (OpenAI-compatible API)
- evaluating with lm-eval (GSM8K, WikiText2 PPL)
- tracking baselines (E0) and quantization experiments (E1+)

## Baselines (E0)
- GSM8K (FULL 1319)
  - strict EM: 0.6141
  - flexible EM: 0.6308
- WikiText2 PPL (word_perplexity): 76.7062

## Where to find results
- `experiments/E0/evals/`
- `experiments/E0/logs/`
