# Lab 1 — 폴더와 파일 (25분)

> 상황: 시퀀싱 센터에서 RNA-seq 데이터 12개(S1~S12)가 도착했습니다.
> **S1~S9 는 1차 시퀀싱(run1), S10~S12 는 2차 시퀀싱(run2)** 에서 나왔습니다.
> 목표: 마우스 없이 폴더를 돌아다니고, 파일을 run 별로 정리한다.

✋ 규칙: 명령을 치기 **전에** 결과를 예측해 보세요 (🤔 표시).

## 1. 나는 어디에 있나?

```bash
pwd                 # 지금 있는 위치
ls                  # 이 위치의 파일과 폴더 목록
ls data             # 🤔 data 안에는 무엇이 있을까?
ls data/incoming    # 시퀀싱 파일 12개
cd data             # data 폴더로 들어가기
pwd                 # 🤔 예측:
ls
cd ..               # .. = 한 단계 위로 (원래 자리로)
pwd
```

> ⌨️ **Tab** : `ls data/inc` 까지만 치고 Tab → 나머지가 자동으로 채워집니다
> ⌨️ **↑** : 방금 친 명령 다시 불러오기
> ⌨️ 길을 잃었으면: `cd $REPO` → 실습 저장소 맨 위로 돌아갑니다

## 2. 프로젝트 폴더 만들기

```bash
mkdir work/project                      # 폴더 만들기
mkdir work/project/raw
mkdir work/project/raw/run1 work/project/raw/run2 work/project/ref
ls work/project
ls work/project/raw
```

> 💬 `mkdir: ... File exists` 라는 에러가 나와도 괜찮습니다 — "이미 있다" 는 뜻입니다. 에러 메시지는 읽으면 대부분 이해됩니다!
> 폴더·파일 이름에는 **띄어쓰기를 쓰지 마세요**: `my data` ❌ → `my_data` ⭕

## 3. 와일드카드로 run 별로 나누기

`*` = 아무 글자나 몇 개든, `?` = 아무 글자 **딱 1개**

```bash
ls data/incoming/*.fastq          # 전부
ls data/incoming/S?_R1.fastq      # 🤔 S 다음에 글자 1개 → 몇 개가 나올까?
ls data/incoming/S??_R1.fastq     # 🤔 S 다음에 글자 2개 → 예측:
```

예측이 맞았으면 **복사(cp)** 합니다. 원본(`data/`)은 그대로 둡니다.

```bash
cp data/incoming/S?_R1.fastq  work/project/raw/run1/
cp data/incoming/S??_R1.fastq work/project/raw/run2/
cp data/ref/genome.fasta      work/project/ref/
ls work/project/raw/run1
ls work/project/raw/run2
```

## 4. 이름 바꾸기와 지우기

```bash
cp work/project/ref/genome.fasta work/project/ref/copy.fasta   # 복사본 만들기
ls work/project/ref
mv work/project/ref/copy.fasta work/project/ref/test.fasta     # mv = 이동 / 이름 바꾸기
ls work/project/ref
rm work/project/ref/test.fasta                                 # rm = 삭제. 휴지통 없음!
ls work/project/ref
```

> ⚠️ `rm` 은 되돌릴 수 없습니다. 지우기 전에 `ls` 로 대상을 먼저 확인하는 습관을 들이세요.

## 🤖 AI 활용 (3분)

터미널에서 `Ctrl+I` 를 누르고 한국어로 입력해 보세요:
> "data/incoming 에서 run2 샘플(S10~S12) 파일만 보여줘"

AI가 제안한 명령을 **실행하기 전에**, 각 부분이 무슨 뜻인지 옆 사람에게 설명해 보세요.

## ✅ 확인

```bash
check lab1
```
