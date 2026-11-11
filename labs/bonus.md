# ➕ 더 해보기 (선택 · 채점 없음)

수업이 끝난 뒤 더 해보고 싶은 사람을 위한 과제입니다. 막히면 AI에게 **힌트만** 달라고 해 보세요.

## 1. 왜 BWA 같은 정렬 프로그램이 따로 있을까?
```bash
READ=$(sed -n '2p' data/incoming/S1_R1.fastq)                                  # S1 첫 리드 서열
CHR2=$(sed -n '/^>chr2/,/^>chr3/p' data/ref/genome.fasta | grep -v '>' | tr -d '\n')
time python3 tools/align.py "$READ" "$CHR2" --local                             # Smith-Waterman
grep -v '^@' data/align/S1.sam | head -1                                        # SAM 의 위치(4번째 칸)와 비교
```
50bp 리드 × 5,000bp 에 걸린 시간으로, 사람 유전체(30억 bp) × 리드 3천만 개를 계산하면?

## 2. 발현량 행렬과 awk
```bash
head -3 data/expr/counts.tsv
tail -n +2 data/expr/counts.tsv | sort -k2,2nr | head -5            # S1 에서 가장 높은 유전자
awk 'NR > 1 && $2 > 0 {print $1, $6 / $2}' data/expr/counts.tsv | sort -k2,2nr | head -5   # S5/S1 fold change
```

## 3. Elbow 방법 — 스크립트 함수 완성하기
`scripts/analysis.sh` 의 `run_sweep` 함수(TODO)를 완성해서 `bash scripts/analysis.sh 내이름 sweep 1 6` 이 k 별 WSS 를 출력하게 만드세요.
힌트: `for k in $(seq "$kmin" "$kmax"); do python3 "$ROOT/tools/cluster.py" --k "$k" --wss 2> /dev/null; done`

## 4. 머신러닝: train / test 와 kNN
```bash
mkdir -p work/ml
tail -n +2 data/expr/samples.tsv | shuf > work/ml/all.txt
head -n 8 work/ml/all.txt > work/ml/train.txt
tail -n 4 work/ml/all.txt > work/ml/test.txt
python3 tools/knn.py --train work/ml/train.txt --test work/ml/test.txt --k 3
```
train 과 test 에 같은 파일을 주면 어떤 경고가 나오나요? 왜 문제일까요?

## 5. 생각해 보기: 배치 효과
drugB 샘플(S9~S12) 중 몇 개가 run2(S10~S12)에서 시퀀싱되었나요?
군집이 처리군과 일치하는 것이 약 때문인지, 시퀀싱 run 때문인지 구분할 수 있을까요?
