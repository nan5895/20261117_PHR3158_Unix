#!/bin/bash
# dotplot.sh — Dot plot: 두 서열이 같은 글자인 곳에 점(*)을 찍는다 (수업: Dot matrix)
#
# 사용 예:
#   bash tools/dotplot.sh ACGTTGCAAC ACGTTGCAAC                 # 같은 서열 → 대각선 하나
#   bash tools/dotplot.sh ACGTACGTACGT ACGTACGTACGT             # 반복 서열 → 대각선 여러 개
#   bash tools/dotplot.sh GATTACAGG GGACATTAG                   # 거꾸로 읽은 서열 → ?
#   bash tools/dotplot.sh ACGTTGCAAC ACGTTCCGCAAC               # 중간에 삽입(indel) → ?
#   bash tools/dotplot.sh data/lab1/read.fa data/lab1/read.fa               # 긴 서열 W=1 → 잡음 가득
#   bash tools/dotplot.sh data/lab1/read.fa data/lab1/read.fa --window 5    # window 로 잡음 줄이기
# 가로 = seq1, 세로 = seq2.  --window W : 연속 W 글자를 비교해 --stringency S 글자 이상 같으면 점

usage() {
    echo "사용법: bash tools/dotplot.sh SEQ1 SEQ2 [--window W] [--stringency S]"
    echo "  --window W       비교할 글자 수 (기본 1)"
    echo "  --stringency S   점을 찍을 최소 일치 수 (기본 = W)"
}

WIN=1; STR=""; ARGS=()
while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)    usage; exit 0 ;;
        --window)     WIN=$2; shift ;;
        --stringency) STR=$2; shift ;;
        *)            ARGS+=("$1") ;;
    esac
    shift
done
if [ ${#ARGS[@]} -ne 2 ]; then usage; exit 2; fi
[ -z "$STR" ] && STR=$WIN

load() {  # 파일이면 FASTA ('>' 줄 빼고), 아니면 글자 그대로
    if [ -f "$1" ]; then
        grep -v '^>' "$1" | tr -d '\n\r ' | tr 'a-z' 'A-Z'
    elif [[ "$1" =~ ^[ACGTUNacgtun]+$ ]]; then
        echo "$1" | tr 'a-z' 'A-Z'
    else
        echo "오류: '$1' 는 서열도 아니고, 있는 파일도 아닙니다" >&2
        return 1
    fi
}
s=$(load "${ARGS[0]}") || exit 1
t=$(load "${ARGS[1]}") || exit 1

cols=$(( ${#s} - WIN + 1 ))
if [ $cols -gt 70 ]; then
    echo "# seq1 이 길어서 처음 $((70 + WIN - 1)) 글자만 그립니다" >&2
    cols=70
fi
rows=$(( ${#t} - WIN + 1 ))

# 맨 위 줄: window 가 1 이면 seq1 글자, 아니면 화살표
if [ $WIN -eq 1 ]; then
    line="   "
    for ((i = 0; i < cols; i++)); do line="$line ${s:i:1}"; done
    echo "$line"
else
    echo "    seq1 →"
fi

for ((j = 0; j < rows; j++)); do
    # 왼쪽 이름표: window 가 1 이면 seq2 글자, 아니면 첫 줄에만 ↓
    if [ $WIN -eq 1 ]; then label="${t:j:1}"; elif [ $j -eq 0 ]; then label="↓"; else label=""; fi
    if [ "$label" == "↓" ]; then line=" ↓  "; else line=$(printf "%2s  " "$label"); fi
    for ((i = 0; i < cols; i++)); do
        same=0
        for ((k = 0; k < WIN; k++)); do
            [ "${s:i+k:1}" == "${t:j+k:1}" ] && same=$((same + 1))
        done
        if [ $same -ge $STR ]; then dot="*"; else dot="."; fi
        if [ $WIN -eq 1 ]; then
            if [ $i -eq 0 ]; then line="$line$dot"; else line="$line $dot"; fi
        else
            line="$line$dot"
        fi
    done
    echo "$line"
done
