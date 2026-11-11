#!/bin/bash
#============================================================
# analysis.sh — 미니 RNA-seq 분석 파이프라인
#
# 사용법:  bash scripts/analysis.sh <이름> <모드> <인자1> <인자2>
#
#   모드 qc       : 폴더 안의 모든 FASTQ 의 리드 수를 표로 만들기
#                   인자1=<FASTQ 폴더>   인자2=<결과 파일.tsv>
#   모드 cluster  : 발현량으로 샘플을 k개 그룹으로 군집화하고 실제 처리군과 비교
#                   인자1=<k>            인자2=<결과 파일.tsv>
#   모드 sweep    : ★ 실습 과제 ★ k 를 바꿔 가며 WSS 출력 (elbow 방법)
#                   인자1=<k 최솟값>     인자2=<k 최댓값>
#============================================================

# --help 를 주거나 아무 인자도 없으면 사용법만 보여주고 끝냅니다
if [[ "$1" == "--help" || -z "$1" ]]; then
    sed -n '2,15p' "$0"      # 이 파일의 2~15번째 줄(위 설명)을 그대로 출력
    exit 0
fi

# 이 스크립트가 있는 위치를 기준으로 저장소 맨 위 폴더를 찾습니다 (어디서 실행해도 동작하게)
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
COUNTS="$ROOT/data/expr/counts.tsv"
SAMPLES="$ROOT/data/expr/samples.tsv"

#### 함수(function) 모음 ####

welcome_message() {
    echo "안녕하세요 $1 님, 작업 시작 시각: $(date +"%Y-%m-%d %H:%M:%S")"
    echo ""
}

# 인자가 4개 모두 들어왔는지 확인. 하나라도 비어 있으면( -z ) 사용법을 보여주고 종료(exit 1)
check_arguments() {
    if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ]; then
        echo "인자가 부족합니다." >&2                       # >&2 : 표준 에러로 출력
        echo "사용법: $0 <이름> <모드> <인자1> <인자2>" >&2
        exit 1
    fi
}

# FASTQ 는 리드 1개 = 4줄  (@이름 / 서열 / + / 품질)
run_qc() {
    local fastq_dir=$1
    local out_file=$2
    echo -e "sample\treads" > "$out_file"               # 표의 머리글(헤더)

    for f in "$fastq_dir"/*.fastq; do                     # 폴더 안의 .fastq 파일을 하나씩 f 에 담아 반복
        local sample lines
        sample=$(basename "$f" _R1.fastq)                 # data/incoming/S1_R1.fastq → S1
        lines=$(wc -l < "$f")
        echo -e "$sample\t$(( lines / 4 ))" >> "$out_file"
        echo "  $sample: $(( lines / 4 )) reads"
    done
    echo "→ $out_file 에 저장했습니다"
}

run_cluster() {
    local k=$1
    local out_file=$2
    # 2> /dev/null : 진행 메시지(표준에러)는 버리고, 결과(표준출력)만 파일로
    python3 "$ROOT/tools/cluster.py" --counts "$COUNTS" --k "$k" 2> /dev/null > "$out_file"

    echo "군집 결과 vs 실제 처리군  (개수 / 군집번호 / 처리군)"
    # 두 파일 모두 S1..S12 순서이므로 paste 로 옆에 붙이고, 군집번호(2번째)와 처리군(4번째) 칸만 남겨 센다
    tail -n +2 "$SAMPLES" | paste "$out_file" - | cut -f2,4 | sort | uniq -c
}

# ★ 실습 과제: 아래 함수를 완성하세요 ★
# 목표: k 를 kmin 부터 kmax 까지 바꿔 가며 tools/cluster.py --wss 를 실행해 "k<TAB>WSS" 를 한 줄씩 출력
# 힌트: for k in $(seq "$kmin" "$kmax"); do ... done
run_sweep() {
    local kmin=$1
    local kmax=$2
    echo "TODO: sweep 모드는 아직 구현되지 않았습니다." >&2
    exit 1
}

#===================================================
# 여기서부터 실제 실행이 시작됩니다
#===================================================
name=$1
mode=$2
arg1=$3
arg2=$4

echo "==================================="
echo " $(date +"%Y-%m-%d")   Lab Session"
echo "==================================="

check_arguments "$name" "$mode" "$arg1" "$arg2"
welcome_message "$name"

case "$mode" in
    qc)       run_qc      "$arg1" "$arg2" ;;
    cluster)  run_cluster "$arg1" "$arg2" ;;
    sweep)    run_sweep   "$arg1" "$arg2" ;;
    *)
        echo "알 수 없는 모드: '$mode'  (qc / cluster / sweep 중 선택)" >&2
        exit 1 ;;
esac
