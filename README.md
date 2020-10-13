# CSodium
![Platforms](https://img.shields.io/badge/platforms-macOS%20%7C%20iOS%20%7C%20watchOS-lightgrey.svg)

Cross platform Swift package for the Sodium library (libsodium) using pre-built binaries. 

Unlike other Sodium swift packages that defer to brew or apt-get to distribute the binaries this project uses the new binary target feature on SPM. The reasoning is two-fold:

1. Using brew/apt-get means you can't depend on the package and still build for iOS or watchOS.
1. Making sure we're building to the same version on all platforms.

## Usage

Add the package dependency as usual.

```swift
dependencies: [
  .package(url: "https://github.com/OuterCorner/CSodium.git", from: "1.0.0"),
]
```

## License

This project is licensed under the MIT License - see [LICENSE](LICENSE).

Note the underlying libsodium library [LICENSE](https://github.com/jedisct1/libsodium/blob/master/LICENSE) still applies when using this project.
