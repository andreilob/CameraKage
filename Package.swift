// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CameraKage",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "CameraKage",
            targets: ["CameraKage"]),
    ],
    targets: [
        .target(
            name: "CameraKage",
            path: "Sources"),
        .testTarget(
            name: "CameraKageTests",
            dependencies: ["CameraKage"]),
    ]
)
