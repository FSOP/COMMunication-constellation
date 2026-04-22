import sys
from pathlib import Path
sys.path.append(str(Path(__file__).resolve().parent / "src"))

from stkga.stk_client import STKClient
from stkga.config import STKConfig

stk = STKClient(STKConfig())
stk.connect()

# STK version
try:
    ver = stk.exec("GetSTKVersion *")
    print("STK version:", ver.Item(0) if ver else ver)
except Exception as e:
    print("GetSTKVersion failed:", e)

for cmd in ["UnloadMulti / */Satellite/*", "UnloadMulti / */Constellation/*"]:
    try:
        stk.exec(cmd)
    except Exception:
        pass

# Create reference satellite with OrbitWizard SunSynchronous
stk.exec("New / */Satellite SAT_SEED")
stk.exec("OrbitWizard */Satellite/SAT_SEED SunSynchronous Altitude 880000 LocalTimeAscNode 12:00:00")
print("OrbitWizard SunSynchronous OK")

# Check propagator
try:
    result = stk.exec("GetPropName */Satellite/SAT_SEED")
    print("Propagator:", result.Item(0) if result else result)
except Exception as e:
    print("GetPropName failed:", e)

# Test deprecated Walker syntax (no Type keyword)
print("\n--- Walker deprecated syntax ---")
try:
    stk.exec("Walker */Satellite/SAT_SEED 2 2 1 360 Yes")
    print("Walker (deprecated syntax): OK")
except Exception as e:
    print("Walker (deprecated syntax) FAILED:", e)

# Test new syntax Delta
print("\n--- Walker new syntax Delta ---")
for cmd in ["UnloadMulti / */Satellite/*", "UnloadMulti / */Constellation/*"]:
    try: stk.exec(cmd)
    except: pass
stk.exec("New / */Satellite SAT_SEED2")
stk.exec("OrbitWizard */Satellite/SAT_SEED2 SunSynchronous Altitude 880000 LocalTimeAscNode 12:00:00")
try:
    stk.exec("Walker */Satellite/SAT_SEED2 Type Delta NumPlanes 2 NumSatsPerPlane 2 InterPlanePhaseIncrement 1 ColorByPlane Yes")
    print("Walker Delta (new syntax): OK")
except Exception as e:
    print("Walker Delta (new syntax) FAILED:", e)

# Test new syntax Custom
print("\n--- Walker new syntax Custom ---")
for cmd in ["UnloadMulti / */Satellite/*", "UnloadMulti / */Constellation/*"]:
    try: stk.exec(cmd)
    except: pass
stk.exec("New / */Satellite SAT_SEED3")
stk.exec("OrbitWizard */Satellite/SAT_SEED3 SunSynchronous Altitude 880000 LocalTimeAscNode 12:00:00")
try:
    stk.exec("Walker */Satellite/SAT_SEED3 Type Custom NumPlanes 2 NumSatsPerPlane 2 InterPlanePhaseAngle 30.0 RAANSpacing 180.0 ColorByPlane No ConstellationName WalkerConst")
    print("Walker Custom (new syntax): OK")
except Exception as e:
    print("Walker Custom (new syntax) FAILED:", e)
