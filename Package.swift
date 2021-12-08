// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-experimental-string-processing",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "_StringProcessing",
            targets: ["_StringProcessing"]),
        .library(
            name: "PEG",
            targets: ["PEG"]),
        .library(
            name: "_MatchingEngine",
            targets: ["_MatchingEngine"]),
        .executable(
            name: "VariadicsGenerator",
            targets: ["VariadicsGenerator"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .testTarget(
            name: "UtilTests",
            dependencies: ["_StringProcessing"]),
        .target(
            name: "_MatchingEngine",
            dependencies: []),
        .testTarget(
            name: "MatchingEngineTests",
            dependencies: ["_MatchingEngine"]),
        .target(
            name: "_StringProcessing",
            dependencies: ["_MatchingEngine"]),
        .testTarget(
            name: "RegexTests",
            dependencies: ["_StringProcessing"]),
        .testTarget(
            name: "RegexDSLTests",
            dependencies: ["_StringProcessing"]),
        .target(
            name: "PEG",
            dependencies: ["_MatchingEngine"]),
        .testTarget(
            name: "PEGTests",
            dependencies: ["PEG"]),
        .target(
            name: "PTCaRet",
            dependencies: ["_MatchingEngine"]),
        .testTarget(
            name: "PTCaRetTests",
            dependencies: ["PTCaRet"]),
        .target(
            name: "Algorithms",
            dependencies: ["_StringProcessing", "PEG"]),
        .testTarget(
            name: "AlgorithmsTests",
            dependencies: ["Algorithms"]),

        // MARK: Scripts
        .executableTarget(
            name: "VariadicsGenerator",
            dependencies: [
              .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]),

        // MARK: Exercises
        .target(
          name: "Exercises",
          dependencies: ["_MatchingEngine", "PEG", "PTCaRet", "_StringProcessing"]),
        .testTarget(
          name: "ExercisesTests",
          dependencies: ["Exercises"]),


    ]
)

