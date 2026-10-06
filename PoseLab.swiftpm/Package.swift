// swift-tools-version: 5.9

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "PoseLab",
    platforms: [.iOS("17.0")],
    products: [
        .iOSApplication(
            name: "PoseLab",
            targets: ["AppModule"],
            bundleIdentifier: "com.crisbezz.PoseLab",
            displayVersion: "0.2",
            bundleVersion: "2",
            appIcon: .placeholder(icon: .running),
            accentColor: .presetColor(.indigo),
            supportedDeviceFamilies: [.pad, .phone],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeRight,
                .landscapeLeft,
                .portraitUpsideDown(.when(deviceFamilies: [.pad]))
            ],
            capabilities: [
                .camera(
                    purposeString: "PoseLab uses the camera to track your body and pose a 3D character."
                ),
                .localNetwork(
                    purposeString: "PoseLab connects nearby iPhone and iPad devices for live body-pose preview.",
                    bonjourServiceTypes: ["_poselab-body._tcp"]
                ),
                .incomingNetworkConnections(),
                .outgoingNetworkConnections()
            ],
            appCategory: .graphicsDesign
        )
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            path: "App"
        )
    ]
)
