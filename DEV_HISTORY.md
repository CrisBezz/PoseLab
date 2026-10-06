# PoseLab Development History

## 2026-10-06 — Body V0.2a Remote Camera foundation
- Added Local / iPhone Camera / iPad Monitor modes.
- Added automatic nearby device discovery and connection.
- Added Codable PosePacket transport.
- Added ~20 Hz remote pose sending.
- Added iPad remote 2D stick-skeleton preview.
- Added Swift Playgrounds local-network/Bonjour capabilities.
- Preserved the working local ARKit path.
- Kept Multipeer Connectivity isolated behind RemotePoseLink for later migration to Network framework.

## 2026-10-06 — Body V0.1 iPad conversion
- Converted canonical app to PoseLab.swiftpm for Swift Playgrounds on iPad.
- Added camera capability.
- Added live ARKit joint + bone skeleton visualization.
- Reserved Face module boundary.
