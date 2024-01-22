// swift-tools-version: 5.6

// WARNING:
// This file is automatically generated.
// Do not edit it by hand because the contents will be replaced.

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "Get Started with Machine Learning",
    defaultLocalization: "en",
    platforms: [
        .iOS("16.0"),
        .macOS("16.0")
    ],
    products: [
        .iOSApplication(
            name: "Get Started with Machine Learning",
            targets: ["App"],
            displayVersion: "1.0",
            bundleVersion: "1",
            appIcon: .asset("AppIcon"),
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
                .camera(purposeString: "This sample app uses the camera."),
                .photoLibrary(purposeString: "This sample app uses your photo library."),
                .fileAccess(.userSelectedFiles, mode: .readWrite)
            ]
        )
    ],
    targets: [
        .executableTarget(
            name: "App",
            path: "App",
            resources: [
                .copy("Resources/Dataset"),
                .copy("Resources/rockpaperscissors.mlmodel")
            ]
        )
    ]
)