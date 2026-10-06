# PoseLab Development History

## 2026-10-06 — Body V0.1 iPad conversion
- Converted canonical app to `PoseLab.swiftpm` for Swift Playgrounds on iPad.
- Added camera capability in Package.swift.
- Isolated Body code under App/Body.
- Reserved App/Face module boundary for future facial work.
- Added live ARKit joint + bone stick-skeleton visualization.
- Kept Freeze / Resume.
- Development path is now explicitly iPad-only compatible.

## 2026-10-06 — V0.1 scaffold
- Created SwiftUI / ARKit / RealityKit architecture.
- Added ARBodyTrackingConfiguration.
- Added normalized PoseSnapshot.
- Added initial body-joint visualization and retargeting boundary.
