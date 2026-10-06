# PoseLab AI Handoff

## Current state
Body V0.1 has been converted to an iPad-native Swift Playgrounds app project.

## Canonical app
`PoseLab.swiftpm`

## Active module
PoseLab Body.

## Reserved module
PoseLab Face remains a first-class architectural track. Do not collapse facial work into Body code.

## Current milestone
Open on iPad → run → ARKit body tracking → white joint/bone skeleton overlay → Freeze / Resume.

## Immediate user test
Open `PoseLab.swiftpm` in Swift Playgrounds on a supported physical iPad and verify:
- rear camera launches
- performer is detected
- joint count becomes non-zero
- skeleton follows body
- Freeze and Resume work

## After PASS
Body V0.2:
- bundle one known rigged humanoid character
- explicit ARKit → target joint map
- rest-pose correction
- live rotation retargeting
- preserve target proportions
- Freeze character pose

## Product rule
The performer drives pose. Character-native bone lengths and stylized proportions remain unchanged.
