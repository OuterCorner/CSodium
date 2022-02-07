// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CSodium",
    platforms: [
        .macOS(.v10_10), .iOS(.v9), .watchOS(.v4)
        ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "CSodium",
            targets: ["CSodium"]
        )
    ],
    targets: [
        .binaryTarget(
            name: "CSodium",
            url: "https://github.com/OuterCorner/CSodium/releases/download/1.0.2/CSodium.xcframework.zip",
            checksum: "fe38b42ecf035bb7761c96443bf4ee9938bec2b6d59972efb31dd7650a94d334"
        )
    ]
)
