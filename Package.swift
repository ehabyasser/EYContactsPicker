// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EYContactsPicker",
    platforms: [
        .iOS("12.0"),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "EYContactsPicker",
            targets: ["EYContactsPicker"]),
    ], dependencies: [
        .package(url: "https://github.com/SnapKit/SnapKit.git", from: "5.0.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "EYContactsPicker",
            dependencies: ["SnapKit"]
        ),
        .testTarget(
            name: "EYContactsPickerTests",
            dependencies: ["EYContactsPicker"]),
    ]
)
