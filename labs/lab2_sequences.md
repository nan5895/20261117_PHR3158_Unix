# Lab 2 — 서열 파일 보기 · 세기 · 파이프 (25분)

> 복습: 시퀀서는 DNA 를 짧은 조각(**read**)으로 읽습니다.
> - **FASTA** = 서열만. 참조 유전체에 사용
> - **FASTQ** = 서열 + 품질 점수. 시퀀서가 내놓는 원본

결과는 `work/results/` 폴더에 저장합니다. `>` 는 "화면 대신 파일로 저장".

## 1. 파일 생김새 보기 (항상 이것부터!)

```bash
head data/ref/genome.fasta              # 앞 10줄
head -n 8 data/incoming/S1_R1.fastq     # 앞 8줄 = 리드 2개
less data/ref/genome.fasta              # 한 화면씩 보기 (스페이스 = 다음, q = 나가기)
```

✍️ FASTQ 에서 리드 1개는 몇 줄인가요?

## 2. FASTA 세기

```bash
grep '>' data/ref/genome.fasta          # '>' 가 들어간 줄 = 서열 이름 줄
grep -c '>' data/ref/genome.fasta       # -c : 줄 수만 세기
```
> ⚠️ `'>'` 의 따옴표를 꼭 붙이세요. 빼면 큰일 납니다 (Lab 4 에서 이유를 봅니다).

**Q1.** 서열(염색체) 개수를 저장하세요.
```bash
grep -c '>' data/ref/genome.fasta > work/results/lab2_nseq.txt
cat work/results/lab2_nseq.txt
```

## 3. 파이프 `|` — 명령 이어 붙이기

`A | B` = A 의 출력을 B 의 입력으로. **한 단계씩** 붙이며 결과를 보세요.

```bash
grep -v '>' data/ref/genome.fasta | head -3                   # -v : '>' 가 없는 줄 = 서열만
grep -v '>' data/ref/genome.fasta | wc -c                     # 글자 수.  🤔 이게 유전체 길이일까?
grep -v '>' data/ref/genome.fasta | tr -d '\n' | wc -c        # 줄바꿈 글자(\n)를 지우고 다시 세기
```

✍️ 두 숫자가 다른 이유는?

**Q2.** 유전체 길이(bp)를 `work/results/lab2_genome_len.txt` 에 저장하세요. (마지막 명령 끝에 `> 파일이름`)

## 4. FASTQ 리드 세기

```bash
wc -l data/incoming/S1_R1.fastq         # 전체 줄 수
```

**Q3.** S1 의 리드 수 = 줄 수 ÷ 4. 계산한 숫자를 저장하세요.
```bash
echo 계산한숫자 > work/results/lab2_reads_S1.txt
```

## 🤖 AI 활용 — AI가 알려준 답을 검증하기 (5분)

AI에게 "FASTQ 파일의 리드 수를 세는 명령어" 를 물으면 이런 답을 자주 줍니다:

```bash
grep -c '^@' data/incoming/S1_R1.fastq      # '@' 로 시작하는 줄 세기
```

🤔 실행해서 Q3 의 답과 비교해 보세요. 왜 다를까요?
힌트: `grep '^@' data/incoming/S1_R1.fastq | grep -v '^@S1'` — 이 줄들은 무엇인가요?
(품질 점수 문자에서 `@` 는 31점입니다)

## ✅ 확인

```bash
check lab2
```
