# 🧬 Unix Shell for Bioinformatics — 약대생을 위한 셸 실습

설치 없이 **브라우저만으로** 모두가 같은 리눅스 환경에서 실습합니다.
수업에서 배운 **시퀀싱 → 서열 정렬(DP) → 군집화** 를 셸로 다시 만나 봅니다.

## 0. 시작하기 (5분)

1. 수업 링크(GitHub Classroom)를 눌러 과제를 수락합니다 → 내 저장소가 만들어집니다.
2. 내 저장소에서 초록색 **`<> Code` → `Codespaces` → `Create codespace on main`** 을 누릅니다.
3. 1~2분 기다리면 VS Code 화면이 열리고 아래쪽에 **터미널**이 보입니다.
   (안 보이면 메뉴 `☰ → Terminal → New Terminal`)
4. 터미널에 입력해 보세요:

   ```bash
   pwd
   ls data
   check lab1
   ```

> 💡 Codespace 는 내 컴퓨터가 아니라 **클라우드에 있는 리눅스 컴퓨터**입니다. 실제 연구실의 분석 서버(HPC)에 접속하는 것과 같은 경험입니다.
> 망가뜨려도 괜찮습니다. 삭제하고 다시 만들면 원래대로 돌아옵니다.

## 1. 실습 순서 (3시간 수업)

| | 파일 | 복습하는 개념 | 배우는 셸 | 채점 |
|---|---|---|---|---|
| Lab 1 (25분) | [`lab1_project.md`](labs/lab1_project.md) | 시퀀싱 run, 프로젝트 정리 | `pwd` `ls` `cd` `mkdir` `cp` `mv` `rm`, 와일드카드 `* ?` | `check lab1` |
| Lab 2 (25분) | [`lab2_sequences.md`](labs/lab2_sequences.md) | FASTA / FASTQ, 품질 점수 | `head` `less` `grep` `wc` `tr`, 파이프 `\|`, 저장 `>` | `check lab2` |
| Lab 3 (20분) | [`lab3_alignment.md`](labs/lab3_alignment.md) | **DP 정렬** (Needleman-Wunsch), SAM | 프로그램 실행, `cut \| sort \| uniq -c` | `check lab3` |
| Lab 4 (20분) | [`lab4_script_ai.md`](labs/lab4_script_ai.md) | **k-means 군집화** | 셸 스크립트, **AI 활용과 검증** | `check lab4` |
| 선택 | [`bonus.md`](labs/bonus.md) | 발현량, elbow, kNN, 배치 효과 | `awk`, 스크립트 함수 | 없음 |

모든 Lab 끝에 **🤖 AI 활용** 코너가 있습니다. [`labs/AI_GUIDE.md`](labs/AI_GUIDE.md) (1분 요약)

## 2. 실습 데이터 (`data/`)

가상의 세포주에 **drugA, drugB** 를 처리하고(각 4반복, control 4개) RNA-seq 을 한 실험입니다.

| 경로 | 내용 |
|---|---|
| `incoming/S1_R1.fastq` … `S12_R1.fastq` | 샘플별 시퀀싱 리드 (50bp). S1–S9 = run1, S10–S12 = run2 |
| `ref/genome.fasta` | 참조 유전체 (염색체 3개, 16 kb) |
| `align/S1.sam` … `S12.sam` | 리드를 참조 유전체에 정렬한 결과 |
| `expr/counts.tsv` | 유전자 200개 × 샘플 12개 count 행렬 |
| `expr/samples.tsv` | 샘플별 처리군 (control / drugA / drugB) |
| `expr/panel.txt` | 관심 유전자 10개 |

`tools/` 에는 수업에서 배운 알고리즘을 구현한 프로그램이 있습니다: `align.py` (Needleman-Wunsch / Smith-Waterman), `cluster.py` (k-means), `knn.py` (kNN 분류).

> ⚠️ 모든 서열·발현량은 **교육용으로 만든 가상 데이터**입니다. 실제 생물·약물의 특성을 나타내지 않습니다.

## 3. 제출하기

결과는 `work/` 폴더에 저장합니다. 끝나면 왼쪽 **Source Control(가지 모양 아이콘)** → 메시지 입력 → **Commit** → **Sync Changes**. 자동 채점이 돌아갑니다.

## 4. 막혔을 때

1. 에러 메시지를 **소리 내어** 읽기
2. `man 명령어` / `명령어 --help` / `python3 tools/align.py --help`
3. AI에게 묻기 — [`AI_GUIDE.md`](labs/AI_GUIDE.md) 의 규칙대로
4. 조교/교수에게 질문
5. 원본 파일을 망가뜨렸다면: `git status` 로 확인 → `git restore 파일이름`
