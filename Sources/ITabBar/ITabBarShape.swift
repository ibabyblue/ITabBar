//
//  ITabBarShape.swift
//  ITabBar
//
//  Created by ibabyblue on 2026/05/14.
//  Copyright © 2026 ibabyblue. All rights reserved.
//

/// The background contour used by ``ITabBar``.
public enum ITabBarShape: Sendable {
    /// Draws a straight tab bar without a center curve.
    case plain
    /// Draws an inward center cutout that accommodates the floating action button.
    case concave
    /// Draws an outward center dome beneath the floating action button.
    case convex
}
