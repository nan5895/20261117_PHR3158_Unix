# Lab 2 — BWA + samtools: WGS 리드 정렬하기 (25분)

> Lab 1 에서는 리드 **1개**를 200글자와 정렬했습니다.
> 실제 WGS 는 리드 **수억 개**를 유전체 **30억 글자**에 정렬해야 합니다 → 전용 프로그램 **BWA** 를 씁니다.
> **오늘의 질문: Lab 1 에서 본 chr2:1500 의 다른 글자는 시퀀싱 오류일까, 진짜 변이일까?**

실제 연구실의 WGS 분석 순서와 똑같습니다:

```
 FASTQ (리드)  ──bwa mem──▶  SAM  ──samtools sort──▶  BAM  ──samtools index──▶  확인 (flagstat, tview)
                  ▲
 참조 유전체 ──bwa index (색인, 처음 한 번)
```

📋 이번에도 명령을 **한 줄씩** 복사 → 붙여넣기 → Enter. 긴 명령도 **한 줄**입니다.

## 0. 데이터 보기 (3분)

```bash
ls data/wgs                                # sample1, sample2 의 리드 파일
head -4 data/wgs/sample1_R1.fastq          # R1 의 첫 리드 (4줄 = 리드 1개)
head -4 data/wgs/sample1_R2.fastq          # R2 의 첫 리드
```

✍️ R1 과 R2 의 첫 리드 이름이 같나요? → **paired-end**: DNA 조각 하나를 양쪽 끝에서 읽은 "짝"입니다.
✍️ R1 의 첫 리드는 Lab 1 에서 본 그 리드입니다.

## 1. 참조 유전체 색인 만들기: `bwa index` (3분)

```bash
mkdir work/bwa                               # 작업 폴더
cp data/ref/genome.fasta work/bwa/           # 참조 유전체 복사
bwa index work/bwa/genome.fasta              # 색인 만들기
ls work/bwa                                  # 🤔 파일이 몇 개 생겼나요?
```

> 📖 색인(index) = 책 뒤의 "찾아보기". 리드가 어디에 있는지 빨리 찾게 해 줍니다. **참조 유전체마다 처음 한 번만** 만듭니다.

## 2. 정렬하기: `bwa mem` (5분)

모양: `bwa mem  [참조]  [R1]  [R2]  >  [결과 파일]`

```bash
bwa mem work/bwa/genome.fasta data/wgs/sample1_R1.fastq data/wgs/sample1_R2.fastq > work/bwa/sample1.sam
```

> 💬 화면에 `[M::...]` 같은 글자가 나오는 건 **진행 상황**입니다. 에러가 아니에요.

결과(SAM 파일)를 봅니다. `@` 로 시작하는 머리말 줄은 빼고(`grep -v`), 앞의 2줄만, 1~6번째 칸만:

```bash
grep -v '^@' work/bwa/sample1.sam | head -2 | cut -f1-6
```

| 칸 | 이름 | 뜻 |
|---|---|---|
| 1 | QNAME | 리드 이름 |
| 2 | FLAG | 리드 상태를 숫자로 (짝, 방향 등) |
| 3 | RNAME | **붙은 염색체** |
| 4 | POS | **붙은 위치** (몇 번째 글자부터) |
| 5 | MAPQ | 확신도 (60 = 확실, 0 = 여러 곳에 붙을 수 있음) |
| 6 | CIGAR | `100M` = 100글자가 모두 참조와 나란히 정렬됨 (M 은 "같다"가 아니라 "정렬됨" — 다른 글자도 M) |

✍️ 첫 리드(`sample1.0001`)는 어느 염색체, 몇 번 위치에 붙었나요?
Lab 1 에서 region(1401번부터 시작)의 **51번째**에 붙었으니 → 1400 + 51 = **1451**. BWA 도 같은 답을 냈나요?

## 3. 정리하기: `samtools sort`, `samtools index` (4분)

```bash
samtools sort -o work/bwa/sample1.bam work/bwa/sample1.sam      # 위치 순서로 정렬 + 압축 (SAM → BAM)
samtools index work/bwa/sample1.bam                              # BAM 의 찾아보기(.bai) 만들기
ls -lh work/bwa                                                  # 🤔 SAM 과 BAM, 어느 쪽이 작나요?
```

> 📖 **SAM** = 사람이 읽을 수 있는 글자 파일, **BAM** = SAM 을 압축한 파일. 실제 WGS 의 BAM 은 사람 1명에 50~100 GB!

## 4. 요약 보기: `samtools flagstat` (3분)

```bash
samtools flagstat work/bwa/sample1.bam
```

✍️ `in total` = 전체 리드 수, `mapped` = 참조에 붙은 리드 수. 몇 % 가 붙었나요?
✍️ 안 붙은 리드는 무엇일까요? (예: 시료에 섞여 들어온 세균 같은 **다른 생물의 DNA**, 품질이 아주 나쁜 리드)

**Q1.** flagstat 결과를 파일로 저장합니다.
```bash
samtools flagstat work/bwa/sample1.bam > work/results/lab2_flagstat.txt
```

## 5. 눈으로 보기: `samtools tview` (5분)

chr2:1500 위치에 리드들이 어떻게 쌓였는지 봅니다.

```bash
samtools tview -d T -p chr2:1500 work/bwa/sample1.bam work/bwa/genome.fasta
```

화면 읽는 법:
- **1번째 줄**: 위치 눈금 (`1501` 이 둘째 칸 → **맨 왼쪽 칸 = 1500**)
- **2번째 줄**: 참조 유전체
- **3번째 줄**: 리드들의 다수결 (consensus)
- **4번째 줄부터**: 리드들. `.` `,` = 참조와 **같음** (`.` 정방향, `,` 역방향), 글자 = 참조와 **다름**

🤔 **맨 왼쪽 세로줄**을 위에서 아래로 보세요.
- 여기저기 흩어진 글자 1~2개 → 시퀀서가 잘못 읽은 **오류**
- 한 세로줄이 **전부 같은 글자** → 이 사람 DNA 의 **진짜 변이 (SNV)**. 부모 양쪽에서 같은 변이를 받은 경우 (동형접합)
- (참고) 세로줄의 **절반쯤만** 다른 글자라면 → 부모 한쪽에서만 받은 변이 (이형접합)

**Q2.** chr2:1500 에서 리드들이 읽은 글자(A, C, G, T 중 하나)를 저장하세요. `글자` 를 바꿔서 입력:
```bash
echo 글자 > work/results/lab2_base.txt
```

## ✅ 확인

```bash
check lab2
```

`📨 제출 완료` 가 나오면 끝! (결과는 자동으로 교수님께 제출됩니다)

---
⏱ **빨리 끝났다면**: `-d T` 를 빼고 실행하면 화살표로 움직이며 볼 수 있습니다 (나가기: `q`)
```bash
samtools tview -p chr2:1450 work/bwa/sample1.bam work/bwa/genome.fasta
```
