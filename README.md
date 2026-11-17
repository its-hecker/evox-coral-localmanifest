# Evolution X Android 17 — Google Pixel 4 XL (coral)

Maintainer: **Hecker**. Upstream ROM: [Evolution X](https://github.com/Evolution-X/manifest), branch `cnb`, Android 17.

## Included source repositories

- [evox-coral-dt](https://github.com/its-hecker/evox-coral-dt) — imported from RisingOS, with Evolution X product adaptation.
- [evox-coral-vendor](https://github.com/its-hecker/evox-coral-vendor) — private Pixel 4 XL vendor blobs (the original external LFS server is required for some files).
- [evox-coral-kernel](https://github.com/its-hecker/evox-coral-kernel) — floral Linux 4.14 kernel, retaining its KernelSU submodule.
- [evox-coral-localmanifest](https://github.com/its-hecker/evox-coral-localmanifest) — this manifest and build preparation.

The imported device tree preserves the Pixel 4 XL IR camera / 3D Face HAL, legacy camera NDK and Keymaster/Citadel ABI shims, Motion Sense Oslo plugin overlay, and stock GCam 8.7. The hardware Face HAL is selected instead of Evolution X's generic camera-based face unlock. The vendor includes the signed Camera APK set and calibration dependencies. Actual operation on the Evolution X ROM requires a complete build and on-device tests; a successful import or successful build alone does **not** guarantee a bootable ROM.

## ServerHive first build

```bash
mkdir -p ~/evox-coral
cd ~/evox-coral
repo init -u https://github.com/Evolution-X/manifest -b cnb --git-lfs
git clone https://github.com/its-hecker/evox-coral-localmanifest.git .repo/local_manifests
repo sync -c --fail-fast --no-clone-bundle --no-tags -j4
bash .repo/local_manifests/build.sh
```

The helper prepares the KSU kernel submodule and vendor LFS objects, checks/applies the guarded biometric framework compatibility fix, checks the stock signed GCam payload hashes, and compiles `lineage_coral-cp2a-userdebug` with `m evolution`.

For the release-target `user` variant, run `EVO_BUILD_VARIANT=user bash .repo/local_manifests/build.sh`.

## Important checks

- After sync, confirm source projects are populated at `device/google/coral`, `vendor/google/coral` and `kernel/google/msm-4.14`.
- The device tree's `TARGET_PROVIDES_FACE_UNLOCK_HAL := true` prevents generic Evolution X FaceUnlock being packaged instead of the stock IR hardware service.
- The device-specific `GoogleOsloSystemUIOverlay` contains production SystemUI allowlist entries for Motion Sense plugins. Real-world Oslo plugin loading needs validation on Evolution X.
- `GoogleCameraCoral` uses the original signed 8.7.250.494820638.44 camera APK set; checking the bundle and its split APK modules requires the vendor binaries to be available.
- Evolution X's current Android 17 framework was checked against the guarded face-framework script. If the script refuses to patch after an upstream update, inspect the updated framework source rather than bypassing the guard.
- The vendor tree retains `.lfsconfig` pointing at the original LFS host. The new GitHub repository does not automatically duplicate those LFS binaries.
- No existing RisingOS or InfinityX repository is modified.

## Phone validation after a successful flash

Check boot completion, Face Unlock enrollment/unlock/removal, front/rear camera and portrait/video, Motion Sense radar/music gestures, and Google Camera app signature and version. Collect `adb logcat -b all -d` and `adb shell dmesg` if any of these fail. Do not advertise the port as verified until testing on coral succeeds.
