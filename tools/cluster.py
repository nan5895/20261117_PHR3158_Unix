#!/usr/bin/env python3
"""k-means 샘플 군집화 — 발현량 행렬(유전자 x 샘플)을 받아 샘플을 k개 그룹으로 묶습니다.

처리 순서 (수업에서 배운 그대로):
  1) 평균 count < --min-mean 인 유전자 제거 (발현이 거의 없는 유전자 필터링)
  2) log2(count + 1) 변환
  3) 유전자마다 평균을 빼서 중심화(centering)
  4) k-means (k-means++ 초기화, --n-init 번 반복해서 가장 좋은 결과 선택)

사용 예:
  python3 tools/cluster.py --k 3                         # 표준출력: sample<TAB>cluster
  python3 tools/cluster.py --k 3 --wss                   # 표준출력: k<TAB>WSS  (elbow 방법용)
  python3 tools/cluster.py --k 3 2> /dev/null            # 진행 메시지(표준에러) 숨기기
"""
import argparse
import math
import random
import sys

p = argparse.ArgumentParser(description="k-means clustering of samples")
p.add_argument("--counts", default="data/expr/counts.tsv")
p.add_argument("--k", type=int, required=True)
p.add_argument("--min-mean", type=float, default=10)
p.add_argument("--seed", type=int, default=1)
p.add_argument("--n-init", type=int, default=10)
p.add_argument("--wss", action="store_true", help="군집 내 제곱합(WSS)만 출력")
a = p.parse_args()

with open(a.counts) as f:
    header = f.readline().rstrip("\n").split("\t")
    samples = header[1:]
    rows = []
    for line in f:
        x = line.rstrip("\n").split("\t")
        v = [float(c) for c in x[1:]]
        if sum(v) / len(v) >= a.min_mean:
            lv = [math.log2(c + 1) for c in v]
            mu = sum(lv) / len(lv)
            rows.append([c - mu for c in lv])
print(f"# 사용한 유전자 수: {len(rows)} / 샘플 수: {len(samples)} / k={a.k}", file=sys.stderr)
if not 1 <= a.k <= len(samples):
    sys.exit(f"k 는 1 ~ {len(samples)} 사이여야 합니다")

X = [[r[j] for r in rows] for j in range(len(samples))]  # sample vectors


def d2(u, v):
    return sum((x - y) ** 2 for x, y in zip(u, v))


def kmeans(rng):
    cents = [X[rng.randrange(len(X))]]
    while len(cents) < a.k:                                    # k-means++
        w = [min(d2(x, c) for c in cents) for x in X]
        cents.append(X[rng.choices(range(len(X)), w)[0]] if sum(w) > 0 else X[rng.randrange(len(X))])
    lab = [0] * len(X)
    for _ in range(100):
        new = [min(range(a.k), key=lambda c: d2(x, cents[c])) for x in X]
        if new == lab and _ > 0:
            break
        lab = new
        for c in range(a.k):
            mem = [X[i] for i in range(len(X)) if lab[i] == c]
            if mem:
                cents[c] = [sum(col) / len(mem) for col in zip(*mem)]
    return sum(d2(X[i], cents[lab[i]]) for i in range(len(X))), lab


rng = random.Random(a.seed)
wss, lab = min((kmeans(rng) for _ in range(a.n_init)), key=lambda r: r[0])
if a.wss:
    print(f"{a.k}\t{wss:.1f}")
else:
    order = {}
    for c in lab:                       # 군집 번호를 등장 순서대로 1, 2, 3 ... 으로
        order.setdefault(c, len(order) + 1)
    for s, c in zip(samples, lab):
        print(f"{s}\t{order[c]}")
