// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CSodium",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "CSodium",
            targets: ["CSodium"]
        )
    ],
    targets: [
        .target(
            name: "CSodium"
        )
    ]
)
