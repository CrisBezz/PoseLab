# PoseLab AI Handoff

## Current milestone
ARKit performer tracking → normalized PoseLab pose → visible debug skeleton.

## Implemented
- SwiftUI app shell
- ARBodyTrackingConfiguration
- ARBodyAnchor capture
- PoseSnapshot
- RealityKit joint-sphere visualization
- tracking status + joint count
- freeze/resume

## Immediate next task
Run V0.1 on a supported physical iPad/iPhone and verify tracking.

After PASS:
V0.2 Known Character — bundled rigged humanoid, explicit source→target map, rest-pose correction, live rotation retargeting, Freeze Pose.

## Product rule
Prefer rotation retargeting. Preserve character-native bone lengths and stylized proportions.
