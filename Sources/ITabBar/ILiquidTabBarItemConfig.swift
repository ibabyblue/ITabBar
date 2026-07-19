//
//  ILiquidTabBarItemConfig.swift
//  ITabBar
//
//  Created by ibabyblue on 2026/07/16.
//  Copyright © 2026 ibabyblue. All rights reserved.
//

#if os(iOS) && compiler(>=6.2)
import Foundation

@available(iOS 26.0, *)
/// Describes an item displayed by ``ILiquidTabBar`` on iOS 26 or later.
public struct ILiquidTabBarItemConfig: Sendable, Equatable {
    /// The SF Symbols name displayed while the item is unselected.
    public var icon: String
    /// An optional SF Symbols name displayed while selected; `icon` is reused when this is `nil`.
    public var selectedIcon: String?
    /// The title displayed by the native tab bar item.
    public var title: String
    /// Optional badge text, or `nil` when no badge is displayed.
    public var badge: String?

    /// Creates a native liquid tab bar item configuration.
    ///
    /// - Parameters:
    ///   - icon: The SF Symbols name used for the unselected state.
    ///   - selectedIcon: The SF Symbols name used for the selected state, or `nil` to reuse `icon`.
    ///   - title: The native tab bar item title.
    ///   - badge: Optional badge text, or `nil` to hide the badge.
    public init(
        icon: String,
        selectedIcon: String? = nil,
        title: String,
        badge: String? = nil
    ) {
        self.icon = icon
        self.selectedIcon = selectedIcon
        self.title = title
        self.badge = badge
    }
}
#endif
