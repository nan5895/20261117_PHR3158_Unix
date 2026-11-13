#!/bin/bash
# wgs_pipeline.sh — Lab 2 에서 한 줄씩 친 명령을 "파일 하나"에 모아 둔 것 (= 셸 스크립트)
#
#   실행:  bash scripts/wgs_pipeline.sh
#
# 빈칸(____)이 2개 있습니다. 채우고 Ctrl+S 로 저장한 뒤 실행하세요.
set -e                                            # 중간에 에러가 나면 바로 멈추기
cd "$(dirname "$0")/.."                           # 어느 폴더에서 실행해도 저장소 맨 위에서 시작

SAMPLE=____                                       # ★ 빈칸 1: 분석할 샘플 이름 (ls data/wgs 로 확인)
REF=work/bwa/genome.fasta                         # 참조 유전체

if [ ! -f data/wgs/${SAMPLE}_R1.fastq ]; then     # 샘플 이름이 틀렸으면 친절하게 알려주기
    echo "❌ data/wgs/${SAMPLE}_R1.fastq 파일이 없습니다. 빈칸 1 (SAMPLE=) 을 확인하세요 → ls data/wgs"
    exit 1
fi

# 0) 참조 색인이 없으면 만들기 (Lab 2 의 1번)
if [ ! -f $REF.bwt ]; then
    mkdir -p work/bwa
    cp data/ref/genome.fasta work/bwa/
    bwa index $REF 2> /dev/null
fi

echo "1/4 정렬 (bwa mem)"
bwa mem $REF data/wgs/${SAMPLE}_R1.fastq data/wgs/${SAMPLE}_R2.fastq > work/bwa/$SAMPLE.sam 2> /dev/null

echo "2/4 위치 순서로 정렬 + 압축 (samtools sort)"
samtools sort -o work/bwa/$SAMPLE.bam work/bwa/$SAMPLE.sam 2> /dev/null

echo "3/4 BAM 색인 만들기"
samtools ____ work/bwa/$SAMPLE.bam                # ★ 빈칸 2: BAM 색인(.bai)을 만드는 samtools 명령 (Lab 2 의 3번)

echo "4/4 요약 (samtools flagstat) → work/results/hw_flagstat.txt"
samtools flagstat work/bwa/$SAMPLE.bam > work/results/hw_flagstat.txt
cat work/results/hw_flagstat.txt
echo "✅ 끝! 이제 samtools tview 로 chr2:1500 을 확인하세요"
