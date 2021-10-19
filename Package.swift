// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-experimental-string-processing",
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
            name: "RegexDSL",
            dependencies: ["Regex"]),
        .testTarget(
            name: "RegexDSLTests",
            dependencies: ["RegexDSL"]),
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
        .target(
            name: "Algorithms",
            dependencies: ["Regex", "PEG"]),
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
          dependencies: ["MatchingEngine", "PEG", "PTCaRet", "Regex", "RegexDSL"]),
        .testTarget(
          name: "ExercisesTests",
          dependencies: ["Exercises"]),


    ]
)

