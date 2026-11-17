#!/usr/bin/env bash
set -euo pipefail

[[ -f build/envsetup.sh ]] || { echo "Run this from the Evolution X checkout root" >&2; exit 1; }
[[ -f device/google/coral/lineage_coral.mk ]] || { echo "Pixel 4 XL tree missing" >&2; exit 1; }
[[ -f vendor/google/coral/camera/tools/prepare_camera.py ]] || { echo "Coral vendor camera payload missing" >&2; exit 1; }

git -C kernel/google/msm-4.14 submodule update --init --recursive
git -C vendor/google/coral lfs pull

python3 device/google/coral/faceunlock/tools/apply_framework_fixes.py --check
python3 device/google/coral/faceunlock/tools/apply_framework_fixes.py --apply
python3 vendor/google/coral/camera/tools/prepare_camera.py --check-hashes

export WITH_GMS=true
export EVO_BUILD_TYPE=Unofficial

source build/envsetup.sh
lunch lineage_coral-cp2a-${EVO_BUILD_VARIANT:-userdebug}
m evolution
