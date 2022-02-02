// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-experimental-string-processing",
    products: [
        .executable(
            name: "VariadicsGenerator",
            targets: ["VariadicsGenerator"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "_Unicode",
            dependencies: []),
        .testTarget(
          name: "UnicodeTests",
          dependencies: ["_Unicode"]),
        .executableTarget(
            name: "VariadicsGenerator",
            dependencies: [
              .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]),
    ]
)

