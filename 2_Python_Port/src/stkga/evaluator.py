from __future__ import annotations

import csv
import re
from pathlib import Path
from typing import Optional, Tuple
import math

from .config import MissionConfig
from .constellation import create_reference_satellite_sso_880, create_walker_constellation
from .stk_client import STKClient


def _parse_first_float(text: str) -> float:
    match = re.search(r"[-+]?\d*\.?\d+(?:[eE][-+]?\d+)?", text)
    if not match:
        raise ValueError(f"Could not parse numeric value from: {text}")
    return float(match.group(0))


class STKWalkerEvaluator:
    def __init__(self, stk: STKClient, mission: MissionConfig, log_csv: Optional[Path] = None) -> None:
        self.stk = stk
        self.mission = mission
        self.log_csv = log_csv
        self._eval_count = 0
        if log_csv is not None:
            log_csv.parent.mkdir(parents=True, exist_ok=True)
            with open(log_csv, "w", newline="", encoding="utf-8") as f:
                writer = csv.writer(f)
                writer.writerow(["eval", "num_planes", "sats_per_plane", "total_sats",
                                  "inter_plane_phase_deg", "raan_inc_deg", "coverage_pct"])

    def _build_target_and_coverage(self) -> None:
        #self.stk.exec("New / */AreaTarget Targets")
        #self.stk.exec(
        #   f"SetPosition */AreaTarget/Targets Geodetic {self.mission.target_lat_deg} {self.mission.target_lon_deg} 0"
        #)
        #self.stk.exec(
        #    "SetBoundary */AreaTarget/Targets Ellipse {} {} 0".format(
        #        self.mission.target_ellipse_major_m, self.mission.target_ellipse_minor_m
        #    )
        #)

        self.stk.exec("New / */CoverageDefinition Targets")
        self.stk.exec("Cov */CoverageDefinition/Targets Access AutoRecompute off")
        #self.stk.exec("Cov */CoverageDefinition/Targets Grid AreaOfInterest Custom AreaTarget AreaTarget/Targets")
        self.stk.exec("Cov */CoverageDefinition/Targets Grid AreaOfInterest Global")
        self.stk.exec(
            f"Cov */CoverageDefinition/Targets Grid PointGranularity LatLon {self.mission.grid_granularity_deg}"
        )

    def evaluate(self, x: list[float]) -> Tuple[float, float]:
        """Return two objectives: (-coverage_percent, satellite_count)."""
        # x = [raan_space, ma_space, inter_plane_phase]
        RAAN_increment = round(x[0],2)
        num_planes = math.ceil((360 / RAAN_increment) / 2)        
        true_anomaly_phasing = x[1]
        sats_per_plane = math.ceil(360 / true_anomaly_phasing)
        # For Custom Walker, InterPlaneTrueAnomalyIncrement is in degrees [0, 360)
        inter_plane_phase = round(x[2], 2)
        
        raan_deg = 0.0
        
        # raan_deg = float(x[3])

        if num_planes < 1 or sats_per_plane < 1:
            return 1e6, 1e6

        self.stk.clear_scenario_objects()
        self._build_target_and_coverage()

        ref_name = "SAT_REF_"
        create_reference_satellite_sso_880(
            stk=self.stk,
            sat_name=ref_name,
            raan_deg=raan_deg,
            altitude_m=self.mission.altitude_m,
            sensor_cone_half_angle_deg=self.mission.sensor_cone_half_angle_deg,
        )

        sat_names = create_walker_constellation(
            stk=self.stk,
            ref_sat_name=ref_name,
            num_planes=num_planes,
            sats_per_plane=sats_per_plane,
            inter_plane_phase=inter_plane_phase,
            RAANSpacing=RAAN_increment,
        )

        for sat_name in sat_names:
            self.stk.exec(
                f"Cov */CoverageDefinition/Targets Asset */Satellite/{sat_name}/Sensor/Ant Assign"
            )

        self.stk.exec("New / */CoverageDefinition/Targets/FigureOfMerit Revisit")
        self.stk.exec(
            "Cov */CoverageDefinition/Targets/FigureOfMerit/Revisit FOMDefine Definition CoverageTime Compute Percent"
        )
        self.stk.exec("Graphics */CoverageDefinition/Targets/FigureOfMerit/Revisit Animation off")
        self.stk.exec("Graphics */CoverageDefinition/Targets/FigureOfMerit/Revisit Static off")
        self.stk.exec("Cov */CoverageDefinition/Targets Access Compute")

        report = self.stk.exec(
            'Report_RM */CoverageDefinition/Targets/FigureOfMerit/Revisit Style "New Report"'
        )
        row = str(report.Item(1))
        coverage_percent = _parse_first_float(row.split(",")[0])

        satellite_count = float(num_planes * sats_per_plane)
        self._eval_count += 1
        print(
            f"[Eval #{self._eval_count:03d}] planes={num_planes:3d}  sats/plane={sats_per_plane:3d}  "
            f"total={int(satellite_count):4d}  phase={inter_plane_phase:6.2f}°  "
            f"RAAN_inc={RAAN_increment:6.2f}°  coverage={coverage_percent:6.2f}%"
        )
        if self.log_csv is not None:
            with open(self.log_csv, "a", newline="", encoding="utf-8") as f:
                csv.writer(f).writerow([
                    self._eval_count, num_planes, sats_per_plane, int(satellite_count),
                    inter_plane_phase, RAAN_increment, round(coverage_percent, 4)
                ])
        return -coverage_percent, satellite_count