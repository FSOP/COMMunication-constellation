import math

from .orbit import sso_inclination_deg
from .stk_client import STKClient


def create_reference_satellite_sso_880(
    stk: STKClient,
    sat_name: str,
    raan_deg: float,
    altitude_m: int,
    sensor_cone_half_angle_deg: float,
) -> float:
    altitude_km = altitude_m / 1000.0
    inclination_deg = sso_inclination_deg(altitude_km)

    stk.exec(f"New / */Satellite {sat_name}")
    stk.exec(f"New / */Satellite/{sat_name}/Sensor Ant")
    stk.exec(
        f"Define */Satellite/{sat_name}/Sensor/Ant SimpleCone {sensor_cone_half_angle_deg:.3f}"
    )
    stk.exec(
        f"OrbitWizard */Satellite/{sat_name} SunSynchronous Altitude {int(altitude_m)} LocalTimeAscNode 12:00:00"
    )

    return inclination_deg


def create_walker_constellation(
    stk: STKClient,
    ref_sat_name: str,
    num_planes: int,
    sats_per_plane: int,
    inter_plane_phase: float,
    RAANSpacing: float,
) -> list[str]:
    walker_command = (
        "Walker */Satellite/{} Type Custom NumPlanes {} NumSatsPerPlane {} "
        "InterPlaneTrueAnomalyIncrement {} RAANIncrement {} ColorByPlane No ConstellationName WalkerConst".format(
            ref_sat_name,
            num_planes,
            sats_per_plane,
            round(inter_plane_phase, 2),
            round(RAANSpacing, 2),
        )
    )
    print(f"STK command: {walker_command}")
    stk.exec(walker_command)

    plane_digits = int(math.floor(math.log10(num_planes)) + 1) if num_planes > 0 else 1
    sat_digits = int(math.floor(math.log10(sats_per_plane)) + 1) if sats_per_plane > 0 else 1

    sat_names = []
    for p in range(1, num_planes + 1):
        for s in range(1, sats_per_plane + 1):
            sat_names.append(
                f"{ref_sat_name}{p:0{plane_digits}d}{s:0{sat_digits}d}"
            )

    return sat_names
