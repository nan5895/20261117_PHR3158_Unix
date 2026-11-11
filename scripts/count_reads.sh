#!/bin/bash
# count_reads.sh — data/incoming 안의 모든 FASTQ 파일의 리드 수를 출력합니다
# 실행 방법:  bash scripts/count_reads.sh

for f in data/incoming/*.fastq          # FASTQ 파일을 하나씩 f 라는 이름에 담아서 반복
do
    lines=$(wc -l < "$f")               # 파일 f 의 줄 수를 세서 lines 에 저장
    reads=$(( lines / ____ ))           # ★ 빈칸: FASTQ 는 리드 1개가 몇 줄인가요?
    echo "$f    $reads"                 # 파일 이름과 리드 수를 화면에 출력
done
