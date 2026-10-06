# PoseLab Development History

## 2026-10-06 — Body V0.2b Remote Monitor Preview
- Added low-bandwidth rear-camera JPEG preview stream from iPhone.
- Added typed remote message framing so pose and preview data coexist.
- Preview throttled to ~5 fps and 640 px maximum dimension.
- Pose transmission remains ~20 Hz and independent of preview frames.
- iPad Monitor now shows full-screen remote camera preview plus live skeleton inset.
- Preserved Local and Camera modes.

## 2026-10-06 — Body V0.2a Remote Camera foundation
- Added Local / iPhone Camera / iPad Monitor modes.
- Added automatic nearby discovery and connection.
- Added Codable pose transport and remote stick-skeleton preview.

## 2026-10-06 — Body V0.1
- Built iPad Swift Playgrounds app.
- Added ARKit body tracking, joints/bones, Freeze / Resume.
