# PoseLab

**Import a character. Become its skeleton.**

PoseLab is an iPad-first native character capture and posing app.

## Modules

### PoseLab Body — active
ARKit body tracking → normalized body pose → live skeleton → character retargeting.

### PoseLab Face — planned
TrueDepth/ARKit face capture → facial fitting → stylized live preview → expression retargeting.

## iPad-only development

The canonical app now lives in:

`PoseLab.swiftpm`

It is structured as a Swift Playgrounds App project so development and testing can be done entirely on iPad.

### First test
1. Download/clone the repo to the iPad.
2. Open `PoseLab.swiftpm` in Swift Playgrounds.
3. Run on the physical iPad.
4. Allow camera access.
5. Stand in view of the rear camera.
6. PoseLab should draw a white tracked skeleton over your body.
7. Test **Freeze Pose** and **Resume**.

## Current milestone
**Body V0.1 — Live Skeleton**

After PASS:
**Body V0.2 — Known Character Retargeting**
