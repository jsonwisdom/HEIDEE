// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "AppleBlossomCore",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "AppleBlossomCore", targets: ["AppleBlossomCore"]),
        .executable(name: "apple-blossom-gate00", targets: ["Gate00Replay"]),
        .executable(name: "apple-blossom-gate02-ui", targets: ["AppleBlossom"])
    ],
    targets: [
        .target(name: "AppleBlossomCore"),
        .executableTarget(name: "Gate00Replay", dependencies: ["AppleBlossomCore"]),
        .executableTarget(name: "AppleBlossom", dependencies: ["AppleBlossomCore"]),
        .testTarget(name: "AppleBlossomCoreTests", dependencies: ["AppleBlossomCore"])
    ]
)
