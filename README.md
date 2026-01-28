# LG Aimers EXAONE 경량화/양자화 실험 레포 (E0 →)

이 레포는 EXAONE 모델을 **vLLM(OpenAI 호환 API)** 로 서빙하고,
**동일 조건으로 재현 가능한 베이스라인(E0)** 을 만든 뒤,
E1(E2...)에서 양자화 실험을 “딸깍” 실행할 수 있게 관리하기 위한 실험 프레임워크입니다.

---

## 지금까지 완료(E0 Baseline)

### 1) vLLM 서빙 확인
- `/v1/models` 정상 응답
- `/v1/chat/completions` 정상 응답
- 모델 루트 경로(root): 예) `/home/gjustin1/lg_aimers/model`

### 2) 평가 Baseline 저장
- **GSM8K full (1319문항)**:
  - flexible-extract EM ≈ 0.6308
  - strict-match EM ≈ 0.6141
- **WikiText2 PPL(조기 경보용)**:
  - word_perplexity ≈ 76.7062

### 3) 실험 구조 리팩토링 완료
- 공용 실행 로직: `scripts/`
- 실험별 설정/결과: `experiments/E*/`
- 마스터키 실행기: `run_experiment.sh`

---

## 폴더 구조

```text
lg_aimers_repo/
├── run_experiment.sh          # 마스터키: ./run_experiment.sh E0 eval 같은 형태로 실행
├── scripts/                   # 공용 실행 로직(복붙 금지/중복 제거)
│   ├── run_server.sh
│   ├── run_eval.sh
│   └── run_quantize.sh        # (E1부터 사용, 있으면)
└── experiments/
    ├── E0/
    │   ├── config.env         # E0 전용 설정(모델명/포트/URL/토크나이저 경로 등)
    │   ├── evals/             # 결과(json) 저장 폴더
    │   ├── logs/              # 서버 로그
    │   └── notes/             # 메모/모델 크기 등
    └── E1/ ...                # 양자화 실험(추가 예정)
