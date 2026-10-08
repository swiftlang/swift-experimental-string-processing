// swift-tools-version:6.0
import PackageDescription

let availabilityDefinition = PackageDescription.SwiftSetting.unsafeFlags([
    "-Xfrontend",
    "-define-availability",
    "-Xfrontend",
    "SwiftStdlib 5.7:macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0",
    "-Xfrontend",
    "-define-availability",
    "-Xfrontend",
    "SwiftStdlib 5.8:macOS 13.3, iOS 16.4, watchOS 9.4, tvOS 16.4",
    "-Xfrontend",
    "-define-availability",
    "-Xfrontend",
    "SwiftStdlib 5.9:macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0",
    "-Xfrontend",
    "-define-availability",
    "-Xfrontend",
    "SwiftStdlib 5.10:macOS 9999, iOS 9999, watchOS 9999, tvOS 9999",
    "-Xfrontend",
    "-define-availability",
    "-Xfrontend",
    "SwiftStdlib 6.0:macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0",
    "-Xfrontend",
    "-define-availability",
    "-Xfrontend",
    "SwiftStdlib 6.1:macOS 15.4, iOS 18.4, watchOS 11.4, tvOS 18.4, visionOS 2.4",
    "-Xfrontend",
    "-define-availability",
    "-Xfrontend",
    "SwiftStdlib 6.2:macOS 26.0, iOS 26.0, watchOS 26.0, tvOS 26.0, visionOS 26.0",
    "-Xfrontend",
    "-define-availability",
    "-Xfrontend",
    "SwiftStdlib 6.3:macOS 26.4, iOS 26.4, watchOS 26.4, tvOS 26.4, visionOS 26.4",
    "-Xfrontend",
    "-define-availability",
    "-Xfrontend",
    "SwiftStdlib 6.4:macOS 27.0, iOS 27.0, watchOS 27.0, tvOS 27.0, visionOS 27.0",
    "-Xfrontend",
    "-define-availability",
    "-Xfrontend",
    "SwiftStdlib 6.5:macOS 9999, iOS 9999, watchOS 9999, tvOS 9999, visionOS 9999",
])

/// Swift settings for building a private stdlib-like module that is to be used
/// by other stdlib-like modules only.
let privateStdlibSettings: [PackageDescription.SwiftSetting] = [
    .unsafeFlags(["-Xfrontend", "-disable-implicit-concurrency-module-import"]),
    .unsafeFlags(["-Xfrontend", "-disable-implicit-string-processing-module-import"]),
    .enableUpcomingFeature("MemberImportVisibility"),
]

/// Swift settings for building a user-facing stdlib-like module.
let publicStdlibSettings: [PackageDescription.SwiftSetting] = [
    .unsafeFlags(["-enable-library-evolution"]),
    .unsafeFlags(["-Xfrontend", "-disable-implicit-concurrency-module-import"]),
    .unsafeFlags(["-Xfrontend", "-disable-implicit-string-processing-module-import"]),
    .enableUpcomingFeature("MemberImportVisibility"),
    availabilityDefinition
]

let package = Package(
    name: "swift-experimental-string-processing",
    products: [
        .library(
            name: "_StringProcessing",
            targets: ["_StringProcessing"]),
        // FIXME: Disabled due to rdar://94763190.
        // .library(
        //     name: "Prototypes",
        //     targets: ["Prototypes"]),
        .library(
            name: "_RegexParser",
            targets: ["_RegexParser"]),
        .executable(
            name: "VariadicsGenerator",
            targets: ["VariadicsGenerator"]),
// Disable to work around rdar://126877024
        .executable(
          name: "RegexBenchmark",
          targets: ["RegexBenchmark"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "_RegexParser",
            dependencies: [],
            exclude: ["CMakeLists.txt"],
            packageAccess: false,
            swiftSettings: privateStdlibSettings),
        .testTarget(
            name: "MatchingEngineTests",
            dependencies: [
                "_RegexParser", "_StringProcessing"
            ]),
        .target(
            name: "_CUnicode",
            dependencies: []),
        .target(
            name: "_StringProcessing",
            dependencies: [
              "_RegexParser",
              "_CUnicode",
            ],
            exclude: ["CMakeLists.txt", "_CUnicode"],
            packageAccess: false,
            swiftSettings: publicStdlibSettings),
        .target(
            name: "RegexBuilder",
            dependencies: ["_StringProcessing", "_RegexParser"],
            packageAccess: false,
            swiftSettings: publicStdlibSettings),
        .target(name: "TestSupport",
                swiftSettings: [availabilityDefinition]),
        .testTarget(
            name: "RegexTests",
            dependencies: ["_StringProcessing", "RegexBuilder", "TestSupport"],
            swiftSettings: [
                availabilityDefinition
            ]),
        .testTarget(
            name: "RegexBuilderTests",
            dependencies: ["_StringProcessing", "RegexBuilder", "TestSupport"],
            swiftSettings: [
                availabilityDefinition
            ]),
        .testTarget(
            name: "DocumentationTests",
            dependencies: ["_StringProcessing", "RegexBuilder"],
            swiftSettings: [
                availabilityDefinition,
                .unsafeFlags(["-enable-bare-slash-regex"]),
            ]),
        
        // FIXME: Disabled due to rdar://94763190.
        // .testTarget(
        //     name: "Prototypes",
        //     dependencies: ["_RegexParser", "_StringProcessing"],
        //     swiftSettings: [
        //         .unsafeFlags(["-Xfrontend", "-disable-availability-checking"])
        //     ]),

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
                "_RegexParser",
                "_StringProcessing"
            ]),
        .executableTarget(
            name: "RegexTester",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "_RegexParser",
                "_StringProcessing"
            ],
            swiftSettings: [availabilityDefinition]),
        .executableTarget(
            name: "RegexBenchmark",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "_RegexParser",
                "_StringProcessing",
                "RegexBuilder"
            ],
            swiftSettings: [
                .unsafeFlags(["-Xfrontend", "-disable-availability-checking"]),
            ]),

        // MARK: Exercises
        .target(
            name: "Exercises",
            dependencies: ["_RegexParser", "_StringProcessing", "RegexBuilder"],
            swiftSettings: [
                .unsafeFlags(["-Xfrontend", "-disable-availability-checking"])
            ]),
        .testTarget(
            name: "ExercisesTests",
            dependencies: ["Exercises"],
            swiftSettings: [
                .unsafeFlags(["-Xfrontend", "-disable-availability-checking"])
            ])
    ]
)
