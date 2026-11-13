# Lab 1 — 서열 정렬: 리드 1개를 참조 유전체에 맞춰 보기 (20분)

> **상황**: 어떤 사람(sample1)의 DNA 를 WGS(전장 유전체 시퀀싱)로 읽었습니다.
> 시퀀서가 내놓은 리드 중 **첫 번째 리드 하나**를 꺼내서, 참조 유전체의 한 구간과 비교해 봅니다.
> **이 리드는 참조 유전체와 똑같을까?**

📋 **사용법**: 회색 상자의 명령을 **한 줄씩** 복사(Ctrl+C) → 터미널에 붙여넣기(Ctrl+V) → Enter.
`#` 뒤는 설명이라 같이 붙여넣어도 괜찮습니다. 길을 잃으면 `cd $REPO` (처음 위치로).

## 0. 준비 운동 (3분)

```bash
pwd                          # 지금 내 위치
ls                           # 여기 있는 폴더들
ls data/lab1                 # 이번 실습 파일 2개
cat data/lab1/read.fa        # 리드 1개 (100글자)          cat = 파일 내용 보기
cat data/lab1/region.fa      # 참조 유전체 chr2 의 1401~1600번 (200글자)
```

> ⌨️ **Tab**: `cat data/lab1/re` 까지 치고 Tab → 파일 이름이 자동 완성됩니다
> ⌨️ **↑**: 방금 친 명령이 다시 나옵니다

## 1. 글자 그대로 찾기: `grep` (4분)

`grep -c 단어 파일` = 파일에서 그 단어가 들어 있는 줄 수를 셉니다. (1 = 있음, 0 = 없음)

```bash
grep -c CAATCCGAACTA data/lab1/region.fa       # 리드의 앞 12글자
grep -c CAATCCGAACTATCTATTCCCAGAAGTATGCCGGTCGAAAGACTCCTGACGGAAGCAAGACATCAGCTGAACACCAAAAAGAGCTGCAACTATAAAGAGT data/lab1/region.fa   # 리드 전체
```

🤔 앞 12글자는 찾았는데(1), **리드 전체는 못 찾습니다(0)**. 왜일까요?
→ 어딘가 **글자가 다르기** 때문입니다. `grep` 은 한 글자만 달라도 못 찾습니다.
→ 다른 글자를 허용하며 비교하는 방법 = 수업에서 배운 **정렬(alignment)**

## 2. 수업 예제를 컴퓨터로: Needleman-Wunsch (5분)

`tools/align.py` 는 수업에서 배운 DP 정렬 프로그램입니다. (점수: 일치 +1, 불일치 −1, gap −2)

```bash
python3 tools/align.py AATC AAGC --matrix
```

✍️ 화면의 표가 수업 슬라이드의 DP 행렬과 같은가요? **오른쪽 아래 숫자 = 최종 점수**

**Q1.** 정렬 점수를 파일로 저장합니다. (`>` = 화면 대신 파일에 저장)
```bash
python3 tools/align.py AATC AAGC | grep score > work/results/lab1_score.txt
cat work/results/lab1_score.txt
```

## 3. 리드를 참조에 정렬: Smith-Waterman (6분)

이번엔 서열 대신 **파일 이름**을 넣습니다. `--local` = 지역 정렬 (짧은 리드를 긴 참조 안에서 찾을 때)

```bash
python3 tools/align.py data/lab1/read.fa data/lab1/region.fa --local
```

화면 읽는 법:
- `seq2 위치: 51-150` → 리드가 region 의 51~150번째 글자에 붙었다
- 가운데 줄 `|` = 같음, `.` = **다름**
- `불일치:` 줄 → 다른 글자가 region 의 몇 번째인지

**Q2.** 다른 글자는 region 의 **몇 번째** 글자인가요? 아래의 `숫자` 를 바꿔서 입력합니다.
```bash
echo 숫자 > work/results/lab1_mutation.txt
```

> 💡 region 은 chr2 의 **1401번**부터 시작합니다. 그러니 region 의 100번째 = 염색체 위치 **chr2:1500** (1400 + 100)

## ✅ 확인

```bash
check lab1
```

✔ 가 모두 나오면 통과! ✘ 가 나오면 노란 **힌트**를 읽고 다시 해 보세요.

🤔 **생각해 보기**: 이 다른 글자 하나는 시퀀서가 잘못 읽은 **오류**일까요, 이 사람 DNA 의 진짜 **변이**일까요?
리드 1개만으로는 알 수 없습니다 → **Lab 2** 에서 리드 3천 개를 정렬해서 확인합니다.

---
⏱ **빨리 끝났다면**: 수업의 "Can you try?" — gap 점수를 −1 로 바꾸면 행렬이 어떻게 바뀔까요?
```bash
python3 tools/align.py AATC AAGC --matrix --gap -1
```
