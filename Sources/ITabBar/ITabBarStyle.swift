//
//  ITabBarStyle.swift
//  ITabBar
//
//  Created by ibabyblue on 2026/05/14.
//  Copyright © 2026 ibabyblue. All rights reserved.
//

import SwiftUI

/// Visual and layout values shared by an ``ITabBar`` and its default items.
public struct ITabBarStyle: Sendable {
    /// The foreground color of the selected item. The default is `Color.primary`.
    public var selectedColor: Color       = .primary
    /// The foreground color of unselected items. The default is `Color.secondary`.
    public var unselectedColor: Color     = .secondary
    /// The title font of the selected item. The default is a 10-point medium system font.
    public var selectedFont: Font         = .system(size: 10, weight: .medium)
    /// The title font of unselected items. The default is a 10-point regular system font.
    public var unselectedFont: Font       = .system(size: 10, weight: .regular)

    /// An optional solid background color that takes precedence over ``backgroundMaterial``.
    public var backgroundColor: Color?   = nil
    /// The material used when ``backgroundColor`` is `nil`. The default is `.ultraThinMaterial`.
    public var backgroundMaterial: Material = .ultraThinMaterial

    /// The tab bar content height, in points. The default is `56`.
    public var height: CGFloat           = 56
    /// The floating action button diameter, in points. The default is `52`.
    public var fabSize: CGFloat          = 52
    /// The floating action button background color. The default is `Color.blue`.
    public var fabColor: Color           = .blue
    /// Additional horizontal spacing between standard tab items, in points. The default is `0`.
    public var itemSpacing: CGFloat      = 0

    /// The background color of item badges. The default is `Color.red`.
    public var badgeColor: Color         = .red
    /// The badge text font. The default is a 10-point bold system font.
    public var badgeFont: Font           = .system(size: 10, weight: .bold)

    /// The horizontal radius of the concave or convex center curve, in points. The default is `38`.
    public var curveRadius: CGFloat      = 38
    /// The clearance between the floating action button and a concave curve, in points. The default is `8`.
    public var fabGap: CGFloat           = 8
    /// The distance the floating action button protrudes above a convex bar, in points.
    ///
    /// This value also controls the height of the convex dome. The default is `15`.
    public var convexProtrusion: CGFloat = 15

    /// Creates a style with the package defaults.
    public init() {}
}
