# PoseLab Manual Test Checklist

## Body V0.1 — Local regression
- [ ] Local mode opens rear camera.
- [ ] Joint count becomes non-zero.
- [ ] Stick skeleton follows performer.
- [ ] Freeze / Resume works.

## Body V0.2b — Remote Camera / Monitor
- [ ] Build compiles on iPad.
- [ ] Build compiles on iPhone.
- [ ] iPhone Camera and iPad Monitor discover one another.
- [ ] Both show Connected status.
- [ ] iPad receives non-zero joint count.
- [ ] iPad displays remote camera preview.
- [ ] Preview orientation is correct in portrait.
- [ ] Preview orientation is correct in landscape.
- [ ] Skeleton inset updates independently of camera preview.
- [ ] Raise left/right arms and verify correct sides.
- [ ] Squat and torso twist transmit sensibly.
- [ ] Fast motion remains responsive if preview stutters.
- [ ] Freeze Pose on iPad freezes the received pose preview.
- [ ] Resume restarts pose preview.
- [ ] Stop/restart Monitor reconnects cleanly.
