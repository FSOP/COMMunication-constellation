from dataclasses import dataclass


@dataclass(frozen=True)
class STKConfig:
    scenario_name: str = "Python_STK_GA"
    analysis_epoch: str = "1 Jan 2022 03:00:00"
    analysis_period: str = "+1 day"


@dataclass(frozen=True)
class MissionConfig:
    altitude_m: int = 880000
    sensor_cone_half_angle_deg: float = 51.0
    target_lat_deg: float = 37.6
    target_lon_deg: float = 127.0
    target_ellipse_major_m: float = 1000000.0
    target_ellipse_minor_m: float = 1000000.0
    grid_granularity_deg: float = 15


@dataclass(frozen=True)
class OptimizerConfig:
    population_size: int = 20
    generations: int = 5
