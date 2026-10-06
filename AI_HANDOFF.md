# PoseLab AI Handoff

## Current state
Body V0.2a Remote Camera foundation is on main.

## Canonical app
`PoseLab.swiftpm`

## Active module
PoseLab Body.

## Reserved module
PoseLab Face remains a first-class architectural track.

## Current Body modes
- Local — existing rear-camera ARKit skeleton on the current device.
- iPhone Camera — rear-camera ARKit capture plus nearby pose broadcast.
- iPad Monitor — discovers the nearby PoseLab camera and renders the received skeleton without using the iPad rear camera.

## Remote architecture
ARKit tracking and pose transport are separated.
`RemotePoseLink` currently uses Multipeer Connectivity as an MVP transport. It is intentionally isolated because Apple has deprecated Multipeer Connectivity in favour of Network framework.

Pose packets are transport-safe Codable data and do not expose ARKit types to the link layer.

## Immediate test
Install/run the same PoseLab.swiftpm build on iPhone and iPad:
1. iPhone → iPhone Camera.
2. iPad → iPad Monitor.
3. Allow Local Network permission on both devices.
4. Devices should discover/connect automatically.
5. Stand in view of the iPhone rear camera.
6. iPad should show the live stick skeleton and joint count.

## Next after PASS
- remote camera thumbnail/video experiment;
- remote Freeze command;
- known-character retargeting on the iPad monitor.

## Product rule
The performer drives pose. Target character bone lengths/proportions remain native to the character.
