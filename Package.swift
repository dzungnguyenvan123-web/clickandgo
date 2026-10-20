// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ClickAndGo",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "ClickAndGo",
            targets: ["ClickAndGo"]
        )
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "ClickAndGo",
            dependencies: [],
            path: "Sources/ClickAndGo"
        )
    ]
)
