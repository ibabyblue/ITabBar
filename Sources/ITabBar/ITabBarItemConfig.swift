//
//  ITabBarItemConfig.swift
//  ITabBar
//
//  Created by ibabyblue on 2026/05/14.
//  Copyright © 2026 ibabyblue. All rights reserved.
//

import SwiftUI

public struct ITabBarItemConfig: Sendable {
    public var icon: String
    public var selectedIcon: String?
    public var title: String
    public var animation: ITabBarAnimation
    public var badge: String?

    public init(
        icon: String,
        selectedIcon: String? = nil,
        title: String,
        animation: ITabBarAnimation = .bounce,
        badge: String? = nil
    ) {
        self.icon = icon
        self.selectedIcon = selectedIcon
        self.title = title
        self.animation = animation
        self.badge = badge
    }
}

/// Context passed to a `.custom` animation builder on each invocation.
/// - `isSelected`: current selection state of the tab.
/// - `tapTrigger`: a token that flips on every tap on this tab (including re-taps on the
///   currently-selected tab) and on selection changes. Use it to drive replay-able animations
///   (e.g. Lottie) via `.id(ctx.tapTrigger)` or `.onChange(of: ctx.tapTrigger)`.
public struct ITabBarAnimationContext: Sendable, Hashable {
    public let isSelected: Bool
    public let tapTrigger: Bool

    public init(isSelected: Bool, tapTrigger: Bool) {
        self.isSelected = isSelected
        self.tapTrigger = tapTrigger
    }
}

public enum ITabBarAnimation: Sendable {
    case bounce
    case wiggle
    case pop
    case none
    case custom(@MainActor @Sendable (ITabBarAnimationContext) -> AnyView)
}
