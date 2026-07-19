//
//  ITabBarItemConfig.swift
//  ITabBar
//
//  Created by ibabyblue on 2026/05/14.
//  Copyright © 2026 ibabyblue. All rights reserved.
//

import SwiftUI

/// Describes the default visual content and animation of a standard tab item.
public struct ITabBarItemConfig: Sendable {
    /// The SF Symbols name displayed while the item is unselected.
    public var icon: String
    /// An optional SF Symbols name displayed while selected; `icon` is used when this is `nil`.
    public var selectedIcon: String?
    /// The text displayed below the icon.
    public var title: String
    /// The animation performed when the item becomes selected or is tapped again.
    public var animation: ITabBarAnimation
    /// Optional badge text displayed above the icon.
    public var badge: String?

    /// Creates a standard tab item configuration.
    ///
    /// - Parameters:
    ///   - icon: The SF Symbols name used for the unselected state.
    ///   - selectedIcon: The SF Symbols name used for the selected state, or `nil` to reuse `icon`.
    ///   - title: The text displayed below the icon.
    ///   - animation: The selection animation. The default is ``ITabBarAnimation/bounce``.
    ///   - badge: Optional badge text, or `nil` to hide the badge.
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

/// The state passed to a custom item animation builder.
public struct ITabBarAnimationContext: Sendable, Hashable {
    /// A Boolean value indicating whether the item is currently selected.
    public let isSelected: Bool
    /// A token that flips on every tap and selection change for replayable animations.
    ///
    /// Observe this value or use it as a SwiftUI identity to replay an animation when the
    /// currently selected item is tapped again.
    public let tapTrigger: Bool

    /// Creates an animation context.
    ///
    /// - Parameters:
    ///   - isSelected: Whether the item is currently selected.
    ///   - tapTrigger: The current replay token.
    public init(isSelected: Bool, tapTrigger: Bool) {
        self.isSelected = isSelected
        self.tapTrigger = tapTrigger
    }
}

/// The animation applied to a standard tab item when its interaction token changes.
public enum ITabBarAnimation: Sendable {
    /// Applies a vertical spring bounce.
    case bounce
    /// Applies a short rotational wiggle.
    case wiggle
    /// Applies a spring scale pop.
    case pop
    /// Leaves the default item content unanimated.
    case none
    /// Builds custom content from the item selection and tap context on the main actor.
    case custom(@MainActor @Sendable (ITabBarAnimationContext) -> AnyView)
}
