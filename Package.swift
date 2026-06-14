// swift-tools-version: 6.0
//
//  Package.swift
//  ITabBar
//
//  Created by ibabyblue on 2026/05/14.
//  Copyright © 2026 ibabyblue. All rights reserved.
//

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
