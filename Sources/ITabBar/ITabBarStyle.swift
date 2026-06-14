//
//  ITabBarStyle.swift
//  ITabBar
//
//  Created by ibabyblue on 2026/05/14.
//  Copyright © 2026 ibabyblue. All rights reserved.
//

import SwiftUI

public struct ITabBarStyle: Sendable {
    public var selectedColor: Color       = .primary
    public var unselectedColor: Color     = .secondary
    public var selectedFont: Font         = .system(size: 10, weight: .medium)
    public var unselectedFont: Font       = .system(size: 10, weight: .regular)

    public var backgroundColor: Color?   = nil
    public var backgroundMaterial: Material = .ultraThinMaterial
    public var useLiquidGlass: Bool      = false

    public var height: CGFloat           = 56
    public var fabSize: CGFloat          = 52
    public var fabColor: Color           = .blue
    public var itemSpacing: CGFloat      = 0

    public var badgeColor: Color         = .red
    public var badgeFont: Font           = .system(size: 10, weight: .bold)

    public var curveRadius: CGFloat      = 38
    public var fabGap: CGFloat           = 8
    /// convex 模式下 FAB 顶部超出 tab bar 顶部的距离，同时控制 dome 弧的高度
    public var convexProtrusion: CGFloat = 15

    public init() {}
}
