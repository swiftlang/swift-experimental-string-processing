// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MatchingEngine",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "Regex",
            targets: ["Regex"]),
        .library(
            name: "PEG",
            targets: ["PEG"]),
        .library(
            name: "MatchingEngine",
            targets: ["MatchingEngine"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "Util",
            dependencies: []),
        .testTarget(
            name: "UtilTests",
            dependencies: ["Util"]),
        .target(
            name: "MatchingEngine",
            dependencies: ["Util"]),
        .testTarget(
            name: "MatchingEngineTests",
            dependencies: ["MatchingEngine"]),
        .target(
            name: "Regex",
            dependencies: ["Util", "MatchingEngine"]),
        .testTarget(
            name: "RegexTests",
            dependencies: ["Regex"]),
        .target(
            name: "PEG",
            dependencies: ["Util", "MatchingEngine"]),
        .testTarget(
            name: "PEGTests",
            dependencies: ["PEG", "Util"]),
        .target(
            name: "PTCaRet",
            dependencies: ["Util", "MatchingEngine"]),
        .testTarget(
            name: "PTCaRetTests",
            dependencies: ["PTCaRet", "Util"]),
    ]
)

