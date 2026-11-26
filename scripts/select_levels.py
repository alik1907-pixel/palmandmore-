#!/usr/bin/env python3
"""Picks campaign levels 16..N from generated candidates (tools/gen_levels.gd).

Target: mixed-bot clear rate falls from ~0.85 (level 16) to ~0.25 (last level),
with an easier "breather" at the first level of every 5-level world. Long levels
(par > 35 s) are penalized. Writes game/data/levels/NN.json.

usage: select_levels.py <first> <last> cand1.json [cand2.json ...]
"""
import json, os, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
first, last = int(sys.argv[1]), int(sys.argv[2])
cands = []
for path in sys.argv[3:]:
    cands += json.load(open(path))
slots = list(range(first, last + 1))
if len(cands) < len(slots):
    sys.exit(f"need {len(slots)} candidates, have {len(cands)}")

def target(n):
    t = 0.85 - 0.60 * (n - first) / max(last - first, 1)
    if (n - first) % 5 == 0 and n != first:
        t += 0.12          # breather at the start of each world
    return min(t, 0.95)

used = set()
report = []
for n in slots:
    tgt = target(n)
    want_d = (n - first) / max(last - first, 1)
    best, best_cost = None, 1e9
    for i, c in enumerate(cands):
        if i in used:
            continue
        cost = abs(c["bot_clear"] - tgt) * 2.0 + abs(c["difficulty"] - want_d) * 0.6
        cost += max(c["par"] - 35.0, 0.0) * 0.05
        if cost < best_cost:
            best, best_cost = i, cost
    used.add(best)
    c = dict(cands[best])
    spec = {"name": "", "hint": "", "rows": c["rows"], "par": c["par"], "generated": True,
            "seed": c["seed"], "difficulty": c["difficulty"], "bot_clear": c["bot_clear"]}
    with open(os.path.join(ROOT, "game", "data", "levels", f"{n:02d}.json"), "w") as f:
        json.dump(spec, f, ensure_ascii=False, indent=1)
    report.append((n, tgt, c["bot_clear"], c["difficulty"], c["par"]))

for n, tgt, got, d, par in report:
    print(f"{n:2d} target {tgt:.2f}  clear {got:.1f}  d={d:.2f}  par={par:.1f}s")
