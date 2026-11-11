#!/usr/bin/env python3
"""k-최근접 이웃(kNN) 분류기 — 발현 패턴으로 샘플의 처리군(control/drugA/drugB)을 예측합니다.

  --train 파일: 학습에 쓸 샘플 ID 목록 (한 줄에 하나, 첫 번째 칸만 읽음 → samples.tsv 의 줄을 그대로 써도 됨)
  --test  파일: 예측할 샘플 ID 목록
출력(표준출력): sample<TAB>predicted<TAB>true

사용 예:
  python3 tools/knn.py --train work/ml/train.txt --test work/ml/test.txt --k 3
"""
import argparse
import math
import sys
from collections import Counter

p = argparse.ArgumentParser(description="kNN classifier on expression profiles")
p.add_argument("--counts", default="data/expr/counts.tsv")
p.add_argument("--labels", default="data/expr/samples.tsv")
p.add_argument("--train", required=True)
p.add_argument("--test", required=True)
p.add_argument("--k", type=int, default=3)
p.add_argument("--min-mean", type=float, default=10)
a = p.parse_args()


def ids(path):
    out = []
    for line in open(path):
        x = line.split()
        if x and x[0] != "sample":
            out.append(x[0])
    return out


labels = dict(l.rstrip("\n").split("\t")[:2] for l in open(a.labels) if not l.startswith("sample"))
with open(a.counts) as f:
    samples = f.readline().rstrip("\n").split("\t")[1:]
    rows = []
    for line in f:
        v = [float(c) for c in line.rstrip("\n").split("\t")[1:]]
        if sum(v) / len(v) >= a.min_mean:
            rows.append([math.log2(c + 1) for c in v])
vec = {s: [r[j] for r in rows] for j, s in enumerate(samples)}

train, test = ids(a.train), ids(a.test)
bad = [s for s in train + test if s not in vec]
if bad:
    sys.exit(f"알 수 없는 샘플 ID: {bad}")
overlap = set(train) & set(test)
if overlap:
    print(f"# 경고: train 과 test 에 같은 샘플이 있습니다 (데이터 누수!): {sorted(overlap)}", file=sys.stderr)
print(f"# train {len(train)}개, test {len(test)}개, k={a.k}, 유전자 {len(rows)}개", file=sys.stderr)

for s in test:
    near = sorted(train, key=lambda t: sum((x - y) ** 2 for x, y in zip(vec[s], vec[t])))[:a.k]
    votes = Counter(labels[t] for t in near).most_common()
    top = [lab for lab, c in votes if c == votes[0][1]]
    pred = next(labels[t] for t in near if labels[t] in top)  # 동점이면 더 가까운 이웃의 라벨
    print(f"{s}\t{pred}\t{labels[s]}")
