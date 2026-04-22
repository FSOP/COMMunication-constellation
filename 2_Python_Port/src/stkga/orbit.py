import math


MU_EARTH_KM3_S2 = 398600.4418
R_EARTH_KM = 6378.137
J2 = 1.08262668e-3
SECONDS_PER_DAY = 86400.0
TROPICAL_YEAR_DAYS = 365.2422


def sso_inclination_deg(altitude_km: float) -> float:
    """Compute near-circular SSO inclination from J2 nodal precession.

    The target nodal precession is approximately +360 deg/year in inertial space.
    """
    a_km = R_EARTH_KM + altitude_km
    n_rad_s = math.sqrt(MU_EARTH_KM3_S2 / (a_km**3))
    target_raan_rate_rad_s = (2.0 * math.pi) / (TROPICAL_YEAR_DAYS * SECONDS_PER_DAY)

    denom = 1.5 * J2 * n_rad_s * ((R_EARTH_KM / a_km) ** 2)
    cos_i = -target_raan_rate_rad_s / denom
    cos_i = max(-1.0, min(1.0, cos_i))

    return math.degrees(math.acos(cos_i))
