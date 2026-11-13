#!/usr/bin/env python3
"""Dot plot — 두 서열이 같은 글자인 곳에 점(*)을 찍는다 (수업: Dot matrix)

사용 예:
  python3 tools/dotplot.py ACGTTGCAAC ACGTTGCAAC              # 같은 서열 → 대각선 하나
  python3 tools/dotplot.py ACGTACGTACGT ACGTACGTACGT          # 반복 서열 → 대각선 여러 개
  python3 tools/dotplot.py GATTACAGG GGACATTAG                # 거꾸로 읽은 서열 → ?
  python3 tools/dotplot.py ACGTTGCAAC ACGTTCCGCAAC            # 중간에 삽입(indel) → ?
  python3 tools/dotplot.py data/lab1/read.fa data/lab1/read.fa                  # 긴 서열 W=1 → 잡음 가득
  python3 tools/dotplot.py data/lab1/read.fa data/lab1/read.fa --window 5       # window 로 잡음 줄이기
가로 = seq1, 세로 = seq2.  --window W : 연속 W 글자를 비교해 --stringency S 글자 이상 같으면 점
"""
import argparse
import os
import sys

p = argparse.ArgumentParser(description="Dot plot (window / stringency)")
p.add_argument("seq1", help="서열 또는 FASTA 파일")
p.add_argument("seq2", help="서열 또는 FASTA 파일")
p.add_argument("--window", type=int, default=1, help="비교할 글자 수 W (기본 1)")
p.add_argument("--stringency", type=int, default=None, help="점을 찍을 최소 일치 수 S (기본 = W)")
a = p.parse_args()


def load(x):
    if os.path.isfile(x):
        with open(x) as f:
            return "".join(line.strip() for line in f if not line.startswith(">")).upper()
    if any(c not in "ACGTUN" for c in x.upper()):
        sys.exit(f"오류: '{x}' 는 서열도 아니고, 있는 파일도 아닙니다")
    return x.upper()


s, t = load(a.seq1), load(a.seq2)
W = a.window
S = a.stringency if a.stringency is not None else W
cols = len(s) - W + 1
if cols > 70:
    print(f"# seq1 이 길어서 처음 {70 + W - 1} 글자만 그립니다", file=sys.stderr)
    cols = 70
rows = len(t) - W + 1
show_letters = cols <= 70 and W == 1
print("    " + (" ".join(s[:cols]) if show_letters else "seq1 →"))
for j in range(rows):
    line = []
    for i in range(cols):
        hit = sum(1 for k in range(W) if s[i + k] == t[j + k]) >= S
        line.append("*" if hit else ".")
    label = t[j] if W == 1 else ("" if j else "↓")
    print(f"{label:>2}  " + (" " if show_letters else "").join(line))
