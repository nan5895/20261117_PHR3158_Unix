#!/usr/bin/env python3
"""DP 서열 정렬기 — 수업 시간에 배운 Needleman-Wunsch(전역) / Smith-Waterman(지역)

사용 예:
  python3 tools/align.py GATTACA GCATGCT                 # 전역 정렬 (기본 점수: match +1, mismatch -1, gap -2)
  python3 tools/align.py GATTACA GCATGCT --matrix        # DP 점수 행렬까지 출력
  python3 tools/align.py GATTACA GCATGCT --gap -1        # gap 벌점 바꾸기
  python3 tools/align.py ACGTTGCA TTACGTTGCATT --local   # 지역 정렬 (Smith-Waterman)
"""
import argparse
import sys

p = argparse.ArgumentParser(description="DP pairwise alignment (Needleman-Wunsch / Smith-Waterman)")
p.add_argument("seq1")
p.add_argument("seq2")
p.add_argument("--match", type=int, default=1, help="일치 점수 (기본 1)")
p.add_argument("--mismatch", type=int, default=-1, help="불일치 점수 (기본 -1)")
p.add_argument("--gap", type=int, default=-2, help="gap 벌점 (기본 -2)")
p.add_argument("--local", action="store_true", help="지역 정렬(Smith-Waterman)")
p.add_argument("--matrix", action="store_true", help="DP 점수 행렬 출력 (짧은 서열만)")
a = p.parse_args()

s, t = a.seq1.upper(), a.seq2.upper()
n, m = len(s), len(t)
F = [[0] * (m + 1) for _ in range(n + 1)]
if not a.local:
    for i in range(1, n + 1):
        F[i][0] = i * a.gap
    for j in range(1, m + 1):
        F[0][j] = j * a.gap


def sc(i, j):
    return a.match if s[i - 1] == t[j - 1] else a.mismatch


best = (0, 0, 0)
for i in range(1, n + 1):
    for j in range(1, m + 1):
        v = max(F[i - 1][j - 1] + sc(i, j), F[i - 1][j] + a.gap, F[i][j - 1] + a.gap)
        if a.local:
            v = max(0, v)
            if v > best[0]:
                best = (v, i, j)
        F[i][j] = v

if a.matrix:
    if n > 30 or m > 30:
        print("# (서열이 길어서 행렬은 생략합니다)", file=sys.stderr)
    else:
        print("      " + "".join(f"{c:>4}" for c in "-" + t))
        for i in range(n + 1):
            print(f"{('-' + s)[i]:>4}  " + "".join(f"{F[i][j]:>4}" for j in range(m + 1)))
        print()

# traceback
i, j = (best[1], best[2]) if a.local else (n, m)
score = best[0] if a.local else F[n][m]
top, mid, bot = [], [], []
while (i > 0 and j > 0 and F[i][j] > 0) if a.local else (i > 0 or j > 0):
    if i > 0 and j > 0 and F[i][j] == F[i - 1][j - 1] + sc(i, j):
        top.append(s[i - 1]); bot.append(t[j - 1]); mid.append("|" if s[i - 1] == t[j - 1] else ".")
        i, j = i - 1, j - 1
    elif i > 0 and F[i][j] == F[i - 1][j] + a.gap:
        top.append(s[i - 1]); bot.append("-"); mid.append(" ")
        i -= 1
    else:
        top.append("-"); bot.append(t[j - 1]); mid.append(" ")
        j -= 1

print(f"mode:\t{'local (Smith-Waterman)' if a.local else 'global (Needleman-Wunsch)'}")
print(f"params:\tmatch={a.match} mismatch={a.mismatch} gap={a.gap}")
print(f"score:\t{score}")
if a.local:
    print(f"seq1 위치:\t{i + 1}-{best[1]}\nseq2 위치:\t{j + 1}-{best[2]}")
print()
print("  " + "".join(reversed(top)))
print("  " + "".join(reversed(mid)))
print("  " + "".join(reversed(bot)))
