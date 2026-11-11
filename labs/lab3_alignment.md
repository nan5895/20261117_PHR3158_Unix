# Lab 3 — 서열 정렬: DP 와 SAM (20분)

> 복습: **Needleman-Wunsch** (전역 정렬)
> `F(i,j) = max( 대각선 + 일치/불일치 점수,  위 + gap,  왼쪽 + gap )`
>
> 실제 연구에서 정렬은 **프로그램을 셸에서 실행**해서 합니다. 오늘은 수업 알고리즘을 그대로 구현한 `tools/align.py` 를 씁니다.

## 1. 셸에서 프로그램 실행하기

```bash
python3 tools/align.py --help                         # 사용법부터 확인하는 습관!
python3 tools/align.py GATTACA GCATGCT --matrix       # DP 점수 행렬과 정렬 결과
```

✍️ 행렬 왼쪽 위 `G` vs `G` 칸이 왜 `1` 인지 점화식으로 설명해 보세요.

**Q1.** 정렬 점수를 저장하세요.
```bash
python3 tools/align.py GATTACA GCATGCT | grep score > work/results/lab3_nw_score.txt
```

**Q2.** 옵션 `--gap -1` 을 붙여서 gap 벌점을 바꾸면 점수는? → `work/results/lab3_nw_gap1.txt`
🤔 정렬 모양(`-` 개수)도 바뀌나요?

## 2. 정렬 결과(SAM) 요약하기

정렬 프로그램(BWA 등)의 결과는 **SAM** 파일입니다. 탭으로 나뉜 표이고, `@` 로 시작하는 헤더 줄이 있습니다.

```bash
head -n 7 data/align/S1.sam
```

| 칸 | 의미 |
|---|---|
| 1 | 리드 이름 |
| 2 | **FLAG** — 0 = 정방향으로 붙음, 16 = 역방향으로 붙음, **4 = 못 붙음** |
| 3 | 붙은 염색체 (`*` = 없음) |
| 4 | 위치 |

**데이터 요약 만능 공식: `cut | sort | uniq -c`**

```bash
grep -v '^@' data/align/S1.sam | head -3                          # 헤더(@) 빼기
grep -v '^@' data/align/S1.sam | cut -f2 | head                   # 2번째 칸(FLAG)만
grep -v '^@' data/align/S1.sam | cut -f2 | sort | uniq -c         # 정렬해서 같은 것끼리 세기
```

**Q3.** FLAG 별 개수 표 → `work/results/lab3_flag.txt`
✍️ 매핑된 리드(0 + 16)와 안 된 리드(4)는 각각 몇 개인가요?

**Q4.** 같은 공식으로 **3번째 칸(염색체)** 별 리드 수 → `work/results/lab3_chr.txt`

## 🤖 AI 활용 (3분)

`head -n 7 data/align/S1.sam` 결과를 AI에게 붙여넣고 물어보세요:
> "이 SAM 파일의 FLAG 16 과 CIGAR 50M 의 뜻을 설명해 줘"

**검증**: AI의 설명이 위 표와 같은가요? 다르면 `work/ai_log.md` 에 기록하세요.

## ✅ 확인

```bash
check lab3
```
