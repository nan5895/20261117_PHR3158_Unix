# ➕ 더 해보기 (선택 · 채점 없음)

수업이 끝난 뒤 더 해보고 싶은 사람을 위한 과제입니다. 막히면 AI에게 **힌트만** 달라고 해 보세요.

## 1. Dot plot 맞히기 게임 (수업: Dot matrix)
결과를 보기 **전에** 어떤 모양일지 그려 보고 실행하세요. 가로 = seq1, 세로 = seq2.
```bash
bash tools/dotplot.sh ACGTTGCAAC ACGTTGCAAC         # 같은 서열
bash tools/dotplot.sh ACGTACGTACGT ACGTACGTACGT     # 반복 서열 (repeats)
bash tools/dotplot.sh ACGTTGCAAC ACGTTCCGCAAC       # 중간에 삽입 (indel)
bash tools/dotplot.sh data/lab1/read.fa data/lab1/read.fa                # 긴 서열 (window 1): 잡음!
bash tools/dotplot.sh data/lab1/read.fa data/lab1/read.fa --window 5     # window 로 잡음 줄이기
```

## 2. 점수 체계가 바뀌면 "최고의 정렬" 도 바뀐다
```bash
bash tools/align.sh GATTACA GCATGCT --matrix
bash tools/align.sh GATTACA GCATGCT --match 3 --mismatch 1 --gap -1    # 수업의 "Which is the best?" 점수 체계
```

## 3. SAM 파일 더 읽기
```bash
grep -v '^@' work/bwa/sample1.sam | cut -f3 | sort | uniq -c      # 염색체별 리드 수 (* = 안 붙음)
samtools view -c work/bwa/sample1.bam chr2                        # chr2 에 붙은 리드 수 (BAM 색인 덕분에 빠름)
samtools view work/bwa/sample1.bam chr2:1500-1500 | wc -l         # chr2:1500 을 덮는 리드 수 (depth)
```

## 4. 왜 BWA 가 필요할까?
```bash
time bash tools/align.sh data/lab1/read.fa data/lab1/region.fa --local > /dev/null   # 리드 1개 × 200글자
time bwa mem work/bwa/genome.fasta data/wgs/sample1_R1.fastq > /dev/null 2>&1            # 리드 1540개 × 16,000글자
```
사람 유전체(30억 글자) × 리드 6억 개라면 DP 로 몇 년이 걸릴까요? (힌트: DP 시간 ∝ 두 서열 길이의 곱)
