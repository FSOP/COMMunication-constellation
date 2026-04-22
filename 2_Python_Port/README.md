# Python port: STK + Genetic Algorithm

This folder is a Python rewrite of the MATLAB workflow in `1_Finding_N` and `0_Library/STK_Lib`.

## What changed

- Replaced MATLAB COM automation with Python `pywin32`.
- Replaced MATLAB `gamultiobj` with Python NSGA-II (`pymoo`).
- Replaced `OrbitWizard ... RepeatingGroundTrace ...` with a fixed circular **880 km SSO** model.
- SSO inclination is computed from J2 nodal precession and then passed to:
  - `OrbitWizard */Satellite/<name> Circular Inclination <i> Altitude 880000 RAAN <raan>`

## Decision variables

Optimization variables are:

1. `num_planes`
2. `sats_per_plane`
3. `inter_plane_phase`
4. `raan_deg`

Mission orbit is fixed at 880 km SSO.

## Objectives

1. Maximize coverage percent over target area (implemented as `-coverage_percent` for minimization).
2. Minimize total satellites (`num_planes * sats_per_plane`).

## Files

- `run_optimization.py`: entry point
- `src/stkga/stk_client.py`: STK COM client and scenario cleanup
- `src/stkga/constellation.py`: 880 km SSO satellite creation and Walker generation
- `src/stkga/evaluator.py`: coverage setup and objective evaluation
- `src/stkga/orbit.py`: SSO inclination calculation
- `src/stkga/optimizer.py`: NSGA-II optimization

## Usage

1. Start STK 12 (or let script launch it).
2. Install Python packages:

```bash
pip install -r requirements.txt
```

3. Run optimization:

```bash
python run_optimization.py --pop 40 --gen 8
```

## Notes

- STK Connect report styles can differ by STK setup. If report parsing fails, inspect the returned report row text and adjust parser in `evaluator.py`.
- Objective evaluation runs STK access computation each sample, so optimization can be slow.
