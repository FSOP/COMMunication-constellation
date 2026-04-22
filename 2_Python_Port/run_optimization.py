from __future__ import annotations

import argparse
import csv
import math
import sys
from datetime import datetime
from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np

sys.path.append(str(Path(__file__).resolve().parent / "src"))

from stkga.config import MissionConfig, OptimizerConfig, STKConfig
from stkga.evaluator import STKWalkerEvaluator
from stkga.optimizer import run_nsga2
from stkga.stk_client import STKClient


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="STK Walker optimization with 880 km SSO")
    parser.add_argument("--pop", type=int, default=OptimizerConfig.population_size)
    parser.add_argument("--gen", type=int, default=OptimizerConfig.generations)
    return parser


def save_pareto_csv(result, out_path: Path) -> None:
    out_path.parent.mkdir(parents=True, exist_ok=True)
    with open(out_path, "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(["num_planes", "sats_per_plane", "total_sats",
                         "inter_plane_phase_deg", "raan_inc_deg", "coverage_pct"])
        for x_row, f_row in zip(result.X, result.F):
            raan_inc   = round(x_row[0], 4)
            ma_inc     = round(x_row[1], 4)
            phase      = round(x_row[2], 4)
            num_planes = math.ceil((360 / raan_inc) / 2)
            sats_per   = math.ceil(360 / ma_inc)
            total      = num_planes * sats_per
            coverage   = round(-f_row[0], 4)
            writer.writerow([num_planes, sats_per, total, phase, raan_inc, coverage])
    print(f"[Saved] Pareto CSV  -> {out_path}")


def save_pareto_plot(result, all_csv: Path, pareto_csv: Path, out_path: Path) -> None:
    out_path.parent.mkdir(parents=True, exist_ok=True)

    fig, ax = plt.subplots(figsize=(8, 6))

    # 전체 평가 결과 (회색 점)  — X: 위성수, Y: 미커버리지(100-coverage)
    if all_csv.exists():
        all_data = np.loadtxt(all_csv, delimiter=",", skiprows=1)
        if all_data.ndim == 2 and all_data.shape[0] > 0:
            ax.scatter(all_data[:, 3], 100 - all_data[:, 6],
                       c="lightgray", s=20, label="All evaluations", zorder=1)

    # 파레토 프론트 (파란 점 + 선)  — 우하향 곡선 (두 목적 모두 최소화)
    F = result.F.copy()
    sort_idx   = np.argsort(F[:, 1])          # total_sats 오름차순
    total_sats = F[sort_idx, 1]
    uncovered  = 100 + F[sort_idx, 0]         # 100 - coverage%  (F[:,0] = -coverage)
    ax.plot(total_sats, uncovered, "b-o", markersize=7, linewidth=1.5,
            label="Pareto front", zorder=3)

    # 이상점(Ideal) 표시
    ax.scatter([total_sats.min()], [uncovered.min()],
               marker="*", s=180, c="gold", edgecolors="k", zorder=5, label="Ideal corner")

    ax.set_xlabel("Total satellites  (minimize →)", fontsize=12)
    ax.set_ylabel("Uncovered area (%)  (minimize ↓)", fontsize=12)
    ax.set_title("Pareto Front: Satellites vs Uncovered Area (880 km SSO Walker)", fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, linestyle="--", alpha=0.5)
    plt.tight_layout()
    plt.savefig(out_path, dpi=150)
    plt.close(fig)
    print(f"[Saved] Pareto plot -> {out_path}")


def main() -> None:
    args = build_parser().parse_args()

    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    results_dir = Path(__file__).resolve().parent / "results"
    all_csv_path    = results_dir / f"all_evals_{timestamp}.csv"
    pareto_csv_path = results_dir / f"pareto_{timestamp}.csv"
    plot_path       = results_dir / f"pareto_plot_{timestamp}.png"

    stk = STKClient(STKConfig())
    stk.connect()

    evaluator = STKWalkerEvaluator(stk=stk, mission=MissionConfig(), log_csv=all_csv_path)
    result = run_nsga2(evaluator=evaluator, population_size=args.pop, generations=args.gen)

    print("\n=== Pareto decision variables (X) ===")
    print(result.X)
    print("=== Pareto objective values (F) ===")
    print(result.F)

    save_pareto_csv(result, pareto_csv_path)
    save_pareto_plot(result, all_csv_path, pareto_csv_path, plot_path)
    print(f"\n결과 폴더: {results_dir}")


if __name__ == "__main__":
    main()
