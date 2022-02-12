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
            name: "Prototypes",
            targets: ["Prototypes"]),
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
        .target(
            name: "_MatchingEngine",
            dependencies: [],
            swiftSettings: [
                .unsafeFlags(["-enable-library-evolution"])
            ]),
        .testTarget(
            name: "MatchingEngineTests",
            dependencies: [
              "_MatchingEngine", "_StringProcessing"]),
        .target(
            name: "_StringProcessing",
            dependencies: ["_MatchingEngine"],
            swiftSettings: [
                .unsafeFlags(["-enable-library-evolution"]),
                .unsafeFlags(["-Xfrontend", "-enable-experimental-pairwise-build-block"])
            ]),
        .testTarget(
            name: "RegexTests",
            dependencies: ["_StringProcessing"],
            swiftSettings: [
                .unsafeFlags(["-Xfrontend", "-enable-experimental-pairwise-build-block"])
            ]),
        .target(
            name: "Prototypes",
            dependencies: ["_MatchingEngine", "_StringProcessing"]),

        // MARK: Scripts
        .executableTarget(
            name: "VariadicsGenerator",
            dependencies: [
              .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]),
        .executableTarget(
            name: "PatternConverter",
            dependencies: [
              .product(name: "ArgumentParser", package: "swift-argument-parser"),
              "_MatchingEngine",
              "_StringProcessing"
            ]),

        // MARK: Exercises
        .target(
          name: "Exercises",
          dependencies: ["_MatchingEngine", "Prototypes", "_StringProcessing"],
          swiftSettings: [
              .unsafeFlags(["-Xfrontend", "-enable-experimental-pairwise-build-block"])
          ]),
        .testTarget(
          name: "ExercisesTests",
          dependencies: ["Exercises"]),
    ]
)

