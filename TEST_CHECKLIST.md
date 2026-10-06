# PoseLab Manual Test Checklist

## Body V0.1 — Local
- [x] Existing local skeleton path previously runs on iPad.
- [ ] Local mode still opens rear camera.
- [ ] Joint count becomes non-zero.
- [ ] Stick skeleton follows performer.
- [ ] Freeze / Resume still works.

## Body V0.2a — Remote Camera
- [ ] Latest PoseLab.swiftpm compiles on iPad.
- [ ] Latest PoseLab.swiftpm compiles on iPhone.
- [ ] Mode control shows Local / iPhone Camera / iPad Monitor.
- [ ] iPhone Camera requests Local Network permission.
- [ ] iPad Monitor requests Local Network permission.
- [ ] iPad finds iPhone automatically.
- [ ] Both devices show Connected status.
- [ ] iPhone rear-camera body tracking still works.
- [ ] iPad monitor receives a non-zero joint count.
- [ ] iPad monitor shows moving white stick skeleton.
- [ ] Raise left/right arms and verify correct sides.
- [ ] Squat and torso twist transmit sensibly.
- [ ] Freeze Pose on iPad monitor freezes the preview.
- [ ] Resume restarts the preview.
- [ ] Stopping/restarting Monitor reconnects.
