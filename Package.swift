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
            url: "https://github.com/OuterCorner/CSodium/releases/download/1.0.0/CSodium.xcframework.zip",
            checksum: "ce968cae3cf727bdf0c41b2bee884502abeea03bc7a0598b50a14c37ff75bd29"
        )
    ]
)
