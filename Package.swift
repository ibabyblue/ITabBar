// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ITabBar",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "ITabBar", targets: ["ITabBar"]),
    ],
    targets: [
        .target(name: "ITabBar"),
        .testTarget(name: "ITabBarTests", dependencies: ["ITabBar"]),
    ]
)
