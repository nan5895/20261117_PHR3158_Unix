# Lab 4 — 셸 스크립트와 AI (20분)

## Part A. 첫 셸 스크립트 (10분)

셸 스크립트 = **명령어를 모아 둔 파일**. 12개 샘플을 손으로 12번 세는 대신, 한 번에 처리합니다.

1. 왼쪽 탐색기에서 `scripts/count_reads.sh` 를 엽니다.
2. 각 줄의 주석(`#` 뒤)을 읽어 봅니다.
3. **★ 빈칸(`____`) 하나**를 채우고 저장(`Ctrl+S`)합니다. (힌트: Lab 2 에서 리드 수를 어떻게 계산했나요?)
4. 실행:

```bash
bash scripts/count_reads.sh
```

🤔 S1 의 결과가 Lab 2 에서 구한 숫자와 같나요?

### 스크립트로 수업에서 배운 도구 연결하기
`scripts/analysis.sh` 는 발현량 데이터를 **k-means** 로 군집화하는 스크립트입니다. 실행만 해 봅시다.

```bash
bash scripts/analysis.sh 내이름 cluster 3 work/k3.tsv
cat data/expr/samples.tsv                 # 샘플별 실제 처리군
```

✍️ k=3 군집이 실제 처리군(control / drugA / drugB)과 일치하나요? `3` 을 `2` 로 바꾸면?

## Part B. AI 똑똑하게 쓰기 (10분)

먼저 [`AI_GUIDE.md`](AI_GUIDE.md) 를 1분만 훑어보세요.

### 1) AI가 틀린 명령 고치기 🐛

"S1 에서 chr2 에 붙은 리드 수" 를 AI에게 물었더니:
```bash
grep -c chr2 data/align/S1.sam
```

🤔 실행 결과를 **Lab 3 의 Q4 표**와 비교하세요. 1 차이가 나는 이유는? (힌트: `grep chr2 data/align/S1.sam | head -3`)
→ 올바른 숫자를 `work/results/lab4_bug.txt` 에 저장

### 2) 실행해도 될까? O / X 퀴즈 ☠️

AI가 아래 명령을 실행하겠다고 허락을 구합니다. **절대 직접 실행하지 말고** 생각으로만 판단하세요.

| # | 명령어 |
|---|---|
| 1 | `ls data/incoming/*.fastq` |
| 2 | `rm -rf data/incoming/` |
| 3 | `grep -c '>' data/ref/genome.fasta` |
| 4 | `grep -c > data/ref/genome.fasta` |
| 5 | `head data/incoming/S1_R1.fastq > data/incoming/S1_R1.fastq` |

`work/results/lab4_quiz.txt` 에 한 줄씩: `1 O`, `2 X`, …
✍️ 3번과 4번은 따옴표 하나 차이입니다. 4번은 무슨 일을 할까요?

### 3) AI 사용 기록

```bash
cp labs/ai_log_template.md work/ai_log.md
```
오늘 AI를 쓴 경험 중 **1건 이상**을 기록하세요. 핵심은 `- 검증:` 칸입니다.

## ✅ 확인

```bash
check lab4
```

마지막으로 왼쪽 **Source Control** → 메시지 입력 → **Commit** → **Sync Changes** 로 제출!
