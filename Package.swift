// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "zClips",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "zClips", targets: ["zClips"])
    ],
    targets: [
        .executableTarget(
            name: "zClips",
            path: "Sources/zClips"
        )
    ]
)
