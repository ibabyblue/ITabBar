//
//  ILiquidTabBarMinimizeBehavior.swift
//  ITabBar
//
//  Created by ibabyblue on 2026/07/16.
//  Copyright © 2026 ibabyblue. All rights reserved.
//

#if os(iOS) && compiler(>=6.2)
import UIKit

@available(iOS 26.0, *)
/// The native iOS 26 tab bar minimization policy used by ``ILiquidTabBar``.
public enum ILiquidTabBarMinimizeBehavior: Sendable, CaseIterable, Hashable {
    /// Lets UIKit choose the appropriate minimization behavior.
    case automatic
    /// Keeps the tab bar expanded while scrolling.
    case never
    /// Minimizes the tab bar when the user scrolls downward.
    case onScrollDown
    /// Minimizes the tab bar when the user scrolls upward.
    case onScrollUp

    /// The UIKit value corresponding to this package-level option.
    var uiKitValue: UITabBarController.MinimizeBehavior {
        switch self {
        case .automatic:
            .automatic
        case .never:
            .never
        case .onScrollDown:
            .onScrollDown
        case .onScrollUp:
            .onScrollUp
        }
    }
}
#endif
