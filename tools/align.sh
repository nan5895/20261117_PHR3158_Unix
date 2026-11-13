#!/bin/bash
# align.sh — DP 서열 정렬기: 수업 시간에 배운 Needleman-Wunsch(전역) / Smith-Waterman(지역)
#
# 사용 예:
#   bash tools/align.sh AATC AAGC                     # 전역 정렬 (기본 점수: match +1, mismatch -1, gap -2)
#   bash tools/align.sh AATC AAGC --matrix            # DP 점수 행렬까지 출력 (가로 = seq1, 세로 = seq2)
#   bash tools/align.sh AATC AAGC --gap -1            # gap 벌점 바꾸기
#   bash tools/align.sh data/lab1/read.fa data/lab1/region.fa --local
#                                                     # FASTA 파일도 OK. 지역 정렬 (Smith-Waterman)
#
# 이 파일도 "셸 스크립트" 입니다. 변수, if, for, 배열, $(( 계산 )) 만으로 DP 를 계산합니다.

usage() {
    echo "사용법: bash tools/align.sh SEQ1 SEQ2 [--local] [--matrix] [--match N] [--mismatch N] [--gap N]"
    echo ""
    echo "  SEQ1, SEQ2     서열 (예: AATC) 또는 FASTA 파일 이름"
    echo "  --local        지역 정렬 (Smith-Waterman). 없으면 전역 정렬 (Needleman-Wunsch)"
    echo "  --matrix       DP 점수 행렬 출력 (짧은 서열만)"
    echo "  --match N      일치 점수   (기본 1)"
    echo "  --mismatch N   불일치 점수 (기본 -1)"
    echo "  --gap N        gap 벌점    (기본 -2)"
}

# ---------- 1. 옵션 읽기 ----------
MATCH=1; MISMATCH=-1; GAP=-2; LOCAL=0; MATRIX=0
ARGS=()
while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)  usage; exit 0 ;;
        --local)    LOCAL=1 ;;
        --matrix)   MATRIX=1 ;;
        --match)    MATCH=$2; shift ;;
        --mismatch) MISMATCH=$2; shift ;;
        --gap)      GAP=$2; shift ;;
        *)          ARGS+=("$1") ;;
    esac
    shift
done
if [ ${#ARGS[@]} -ne 2 ]; then usage; exit 2; fi

# ---------- 2. 서열 읽기: 파일이면 FASTA ('>' 줄 빼고), 아니면 글자 그대로 ----------
load() {
    if [ -f "$1" ]; then
        grep -v '^>' "$1" | tr -d '\n\r ' | tr 'a-z' 'A-Z'
    elif [[ "$1" =~ ^[ACGTUNacgtun]+$ ]]; then
        echo "$1" | tr 'a-z' 'A-Z'
    else
        echo "오류: '$1' 는 서열도 아니고, 있는 파일도 아닙니다. 경로를 확인하세요 (ls 로 확인, Tab 자동완성)" >&2
        return 1
    fi
}
s=$(load "${ARGS[0]}") || exit 1
t=$(load "${ARGS[1]}") || exit 1
n=${#s}; m=${#t}
W=$((m + 1))                       # 행렬 F 를 1차원 배열로: F[i][j] = F[i*W + j]

# ---------- 3. 첫 행·첫 열: 전역이면 gap 누적, 지역이면 0 ----------
F=()
for ((i = 0; i <= n; i++)); do
    for ((j = 0; j <= m; j++)); do F[i*W+j]=0; done
done
if [ $LOCAL -eq 0 ]; then
    for ((i = 1; i <= n; i++)); do F[i*W]=$((i * GAP)); done
    for ((j = 1; j <= m; j++)); do F[j]=$((j * GAP)); done
fi

sc() {  # sc i j : s 의 i번째 글자와 t 의 j번째 글자가 같으면 match, 다르면 mismatch
    if [ "${s:$1-1:1}" == "${t:$2-1:1}" ]; then SC=$MATCH; else SC=$MISMATCH; fi
}

# ---------- 4. 나머지 칸: 세 방향 중 최대값 (지역 정렬은 max 에 0 을 추가 → 음수 대신 0) ----------
best=0; bi=0; bj=0
for ((i = 1; i <= n; i++)); do
    for ((j = 1; j <= m; j++)); do
        sc $i $j
        # 수업의 점화식 (가로 = seq1 의 i번째, 세로 = seq2 의 j번째)
        diag=$(( F[(i-1)*W + j-1] + SC ))      # S(i-1, j-1) + (mis)match  ↘ 대각선: 두 글자를 맞춤
        vert=$(( F[i*W + j-1]     + GAP ))     # S(i, j-1)   + gap         ↓ 세로: seq2 글자 vs gap
        horz=$(( F[(i-1)*W + j]   + GAP ))     # S(i-1, j)   + gap         → 가로: seq1 글자 vs gap
        v=$diag
        [ $horz -gt $v ] && v=$horz
        [ $vert -gt $v ] && v=$vert
        if [ $LOCAL -eq 1 ]; then
            [ $v -lt 0 ] && v=0
            if [ $v -gt $best ]; then best=$v; bi=$i; bj=$j; fi
        fi
        F[i*W+j]=$v
    done
done

# ---------- 5. 행렬 출력 (강의 슬라이드와 같은 방향: 가로 = seq1, 세로 = seq2) ----------
if [ $MATRIX -eq 1 ]; then
    if [ $n -gt 30 ] || [ $m -gt 30 ]; then
        echo "# (서열이 길어서 행렬은 생략합니다)" >&2
    else
        top="-$s"; side="-$t"
        printf '      '
        for ((i = 0; i <= n; i++)); do printf '%4s' "${top:i:1}"; done
        echo
        for ((j = 0; j <= m; j++)); do
            printf '%4s  ' "${side:j:1}"
            for ((i = 0; i <= n; i++)); do printf '%4d' "${F[i*W+j]}"; done
            echo
        done
        echo
    fi
fi

# ---------- 6. traceback: 끝 칸에서 거꾸로 따라가며 정렬 만들기 ----------
if [ $LOCAL -eq 1 ]; then i=$bi; j=$bj; score=$best; else i=$n; j=$m; score=${F[n*W+m]}; fi
A=""; M=""; B=""            # 위(seq1) / 가운데(| . 공백) / 아래(seq2) 줄 — 앞쪽에 붙여 나감
mism=()                     # 불일치 설명 (앞쪽에 붙여서 seq2 위치 순서가 됨)
while true; do
    if [ $LOCAL -eq 1 ]; then
        [ $i -gt 0 ] && [ $j -gt 0 ] && [ ${F[i*W+j]} -gt 0 ] || break
    else
        [ $i -gt 0 ] || [ $j -gt 0 ] || break
    fi
    a="${s:i-1:1}"; b="${t:j-1:1}"
    if [ $i -gt 0 ] && [ $j -gt 0 ] && { sc $i $j; [ ${F[i*W+j]} -eq $(( F[(i-1)*W+j-1] + SC )) ]; }; then
        A="$a$A"; B="$b$B"
        if [ "$a" == "$b" ]; then M="|$M"; else M=".$M"; mism=("seq2 의 ${j}번째 $b → seq1 은 $a" "${mism[@]}"); fi
        i=$((i - 1)); j=$((j - 1))
    elif [ $i -gt 0 ] && [ ${F[i*W+j]} -eq $(( F[(i-1)*W+j] + GAP )) ]; then
        A="$a$A"; B="-$B"; M=" $M"
        i=$((i - 1))
    else
        A="-$A"; B="$b$B"; M=" $M"
        j=$((j - 1))
    fi
done

# ---------- 7. 결과 출력 ----------
if [ $LOCAL -eq 1 ]; then echo -e "mode:\tlocal (Smith-Waterman)"; else echo -e "mode:\tglobal (Needleman-Wunsch)"; fi
echo -e "params:\tmatch=$MATCH mismatch=$MISMATCH gap=$GAP"
echo -e "score:\t$score"
if [ $LOCAL -eq 1 ]; then
    echo -e "seq1 위치:\t$((i + 1))-$bi"
    echo -e "seq2 위치:\t$((j + 1))-$bj"
fi
if [ ${#mism[@]} -gt 0 ]; then
    desc="${mism[0]}"
    for ((k = 1; k < ${#mism[@]} && k < 3; k++)); do desc="$desc, ${mism[k]}"; done
    [ ${#mism[@]} -gt 3 ] && desc="$desc …"
    echo -e "불일치:\t${#mism[@]}개 — $desc"
fi
echo
echo "  $A"
echo "  $M"
echo "  $B"
