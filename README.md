# CSodium
![Platforms](https://img.shields.io/badge/platforms-macOS%20%7C%20iOS%20%7C%20watchOS%20%7C%20linux-lightgrey.svg)

Cross platform Swift package for the Sodium library (libsodium) using pre-built binaries. 

Unlike other Sodium swift packages that defer to brew or apt-get to distribute the binaries this project bundles the binaries themselves. The reasoning is two-fold:

1. Using brew/apt-get means you can't depend on the package and still build for iOS or watchOS.
1. Making sure we're building to the same version on all platforms.

## Usage

Add the package dependency as usual.

```swift
dependencies: [
  .package(url: "https://github.com/OuterCorner/CSodium.git", from: "0.9.0"),
]
```

For now, and while [SE-0272 - Package Manager Binary Dependencies](https://github.com/apple/swift-evolution/blob/master/proposals/0272-swiftpm-binary-dependencies.md) doesn't land, you still need to add the following to ensure swift compiler can find the libraries.

```swift
.target(
  name: "MyTool",
  dependencies: ["CSodium"],
  linkerSettings: [
    .unsafeFlags(["-L./.build/checkouts/CSodium/Libs/macos"], .when(platforms: [.macOS])),
    .unsafeFlags(["-L./.build/checkouts/CSodium/Libs/ios"], .when(platforms: [.iOS])),
    .unsafeFlags(["-L./.build/checkouts/CSodium/Libs/watchos"], .when(platforms: [.watchOS])),
    .unsafeFlags(["-L./.build/checkouts/CSodium/Libs/ubuntu"], .when(platforms: [.linux])),
  ])
```

## License

This project is licensed under the MIT License - see [LICENSE](LICENSE).

Note the underlying libsodium library [LICENSE](https://github.com/jedisct1/libsodium/blob/master/LICENSE) still applies when using this project.
