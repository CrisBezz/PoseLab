// swift-tools-version: 5.9

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "PoseLab",
    platforms: [
        .iOS("17.0")
    ],
    products: [
        .iOSApplication(
            name: "PoseLab",
            targets: ["AppModule"],
            bundleIdentifier: "com.crisbezz.PoseLab",
            displayVersion: "0.1",
            bundleVersion: "1",
            appIcon: .placeholder(icon: .running),
            accentColor: .presetColor(.indigo),
            supportedDeviceFamilies: [
                .pad,
                .phone
            ],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeRight,
                .landscapeLeft,
                .portraitUpsideDown(.when(deviceFamilies: [.pad]))
            ],
            capabilities: [
                .camera(purposeString: "PoseLab uses the camera to track your body and pose a 3D character.")
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
