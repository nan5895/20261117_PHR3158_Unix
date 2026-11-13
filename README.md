# 🧬 Unix Shell for Bioinformatics — 약대생을 위한 셸 실습

설치 없이 **브라우저만으로** 모두가 같은 리눅스 환경에서 실습합니다.
수업에서 배운 **서열 정렬(DP)** 을 직접 돌려 보고, 실제 연구실과 같은 방법(**BWA + samtools**)으로 WGS 리드를 정렬합니다.

## 0. 시작하기 (5분)

1. GitHub 에 로그인합니다. (계정이 없으면 github.com 에서 가입)
2. 아래 링크를 누르고 **Create codespace** 를 누릅니다.

   👉 **https://codespaces.new/nan5895/20261117_PHR3158_Unix?quickstart=1**

3. 1~2분 기다리면 VS Code 화면이 열리고 아래쪽에 **터미널**이 보입니다.
   (숙제할 때도 **같은 링크**를 누르면 수업 때 쓰던 화면이 그대로 다시 열립니다)
   (안 보이면 메뉴 `☰ → Terminal → New Terminal`)
4. 터미널에 입력해 보세요:

   ```bash
   ls data
   check lab1
   ```

> 💡 Codespace 는 내 컴퓨터가 아니라 **클라우드에 있는 리눅스 컴퓨터**입니다. 실제 연구실의 분석 서버에 접속하는 것과 같은 경험입니다.
> 망가뜨려도 괜찮습니다. 삭제하고 다시 만들면 원래대로 돌아옵니다.

## 1. 실습 순서

| | 파일 | 내용 | 채점 |
|---|---|---|---|
| Lab 1 (20분) | [`lab1_alignment.md`](labs/lab1_alignment.md) | 리드 1개를 참조 유전체에 DP 정렬 (Needleman-Wunsch, Smith-Waterman) | `check lab1` |
| Lab 2 (25분) | [`lab2_bwa_samtools.md`](labs/lab2_bwa_samtools.md) | `bwa index` → `bwa mem` → `samtools sort / index / flagstat / tview` | `check lab2` |
| 📝 숙제 | [`homework.md`](labs/homework.md) | 스크립트로 sample2 분석 | `check hw` |
| 선택 | [`bonus.md`](labs/bonus.md) | dot plot, 점수 체계, SAM 더 읽기 | 없음 |

AI 사용법은 [`labs/AI_GUIDE.md`](labs/AI_GUIDE.md) (1분 요약)

## 2. 실습 데이터 (`data/`)

두 사람(sample1, sample2)의 WGS(전장 유전체 시퀀싱) 데이터입니다.

| 경로 | 내용 |
|---|---|
| `ref/genome.fasta` | 참조 유전체 (염색체 3개, 16,000 글자) |
| `wgs/sample1_R1.fastq`, `sample1_R2.fastq` | sample1 의 paired-end 리드 (100 bp) |
| `wgs/sample2_R1.fastq`, `sample2_R2.fastq` | sample2 의 paired-end 리드 (숙제용) |
| `lab1/read.fa` | sample1 의 첫 번째 리드 1개 |
| `lab1/region.fa` | 참조 유전체 chr2 의 1401~1600번 구간 |

`tools/` 에는 수업에서 배운 알고리즘을 **셸 스크립트로** 구현한 프로그램이 있습니다: `align.sh` (Needleman-Wunsch / Smith-Waterman), `dotplot.sh` (dot plot).

> ⚠️ 모든 서열은 **교육용으로 만든 가상 데이터**입니다. 실제 사람 유전체는 30억 글자, 리드는 수억 개입니다.

## 3. 제출하기

따로 할 일이 없습니다. `check lab1` 처럼 **check 를 실행하면 결과가 자동으로 제출**됩니다.
처음 한 번만 학번과 이름을 묻습니다. 잘못 입력했으면 `check reset` 으로 다시 입력하세요.

> ⚠️ Codespace 를 **삭제하지 마세요.** 삭제하면 실습한 내용이 사라집니다. (30일 동안 안 쓰면 자동 삭제)

## 4. 막혔을 때

1. 에러 메시지를 **소리 내어** 읽기
2. 길을 잃었으면 `cd $REPO` (저장소 맨 위로)
3. `명령어 --help` / `bash tools/align.sh --help`
4. AI에게 묻기 — [`AI_GUIDE.md`](labs/AI_GUIDE.md) 의 규칙대로
5. 조교/교수에게 질문
