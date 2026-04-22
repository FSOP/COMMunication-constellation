from __future__ import annotations

import numpy as np
from pymoo.algorithms.moo.nsga2 import NSGA2
from pymoo.core.problem import Problem
from pymoo.optimize import minimize

from .evaluator import STKWalkerEvaluator


class STKProblem(Problem):
    def __init__(self, evaluator: STKWalkerEvaluator) -> None:        
        # x = [raan_spacing_deg, ma_spacing_deg, inter_plane_phase_deg]
        # raan_spacing 20-45 deg  -> num_planes  4-9
        # ma_spacing   15-30 deg  -> sats/plane 12-24
        # inter_plane_phase 0-180 deg
        super().__init__(n_var=3, n_obj=2, n_ieq_constr=0,
                         xl=np.array([20.0, 15.0,   0.0]),
                         xu=np.array([45.0, 30.0, 180.0]))
        self.evaluator = evaluator

    def _evaluate(self, X, out, *args, **kwargs):
        F = []
        for x in X:
            f1, f2 = self.evaluator.evaluate(x.tolist())
            F.append([f1, f2])
        out["F"] = np.array(F, dtype=float)


def run_nsga2(evaluator: STKWalkerEvaluator, population_size: int, generations: int):
    problem = STKProblem(evaluator)
    algorithm = NSGA2(pop_size=population_size)

    result = minimize(
        problem,
        algorithm,
        termination=("n_gen", generations),
        save_history=False,
        verbose=True,
    )
    return result
