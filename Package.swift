// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "GameStream",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "GameStream", targets: ["GameStream"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "GameStream",
            dependencies: [],
            path: "Sources/GameStream"
        )
    ]
)
