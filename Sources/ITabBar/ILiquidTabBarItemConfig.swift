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
public struct ILiquidTabBarItemConfig: Sendable, Equatable {
    public var icon: String
    public var selectedIcon: String?
    public var title: String
    public var badge: String?

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
