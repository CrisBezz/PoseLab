# PoseLab AI Handoff

## Current state
Body V0.2b Remote Monitor Preview is on main.

## Canonical app
`PoseLab.swiftpm`

## Active module
PoseLab Body.

## Reserved module
PoseLab Face remains a first-class architectural track.

## Current Body modes
- Local — existing rear-camera ARKit skeleton on the current device.
- iPhone Camera — ARKit body capture + pose broadcast + low-bandwidth camera preview.
- iPad Monitor — receives the camera preview and pose stream, displaying the preview full-screen with a skeleton inset.

## Remote architecture
Pose and camera-preview traffic are separate message types.
- Pose: approximately 20 Hz, unreliable.
- Camera monitor JPEG: approximately 5 Hz, max dimension 640 px, JPEG quality ~0.38.

Tracking remains authoritative. Preview frames are disposable and must never stall pose processing.

`RemotePoseLink` currently uses Multipeer Connectivity only as the MVP transport boundary.

## Immediate test
Run the same build on iPhone and iPad:
1. iPhone → iPhone Camera.
2. iPad → iPad Monitor.
3. Allow Local Network permission.
4. Wait for Connected status.
5. Confirm live camera preview appears on iPad.
6. Confirm skeleton inset and joint count update independently.
7. Move quickly and verify pose remains responsive even if preview is choppy.

## Next after PASS
- remote Freeze command so iPad can freeze the iPhone capture itself;
- known-character retargeting on the iPad monitor.

## Product rule
The performer drives pose. Target character bone lengths/proportions remain native to the character.
