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
public enum ILiquidTabBarMinimizeBehavior: Sendable, CaseIterable, Hashable {
    case automatic
    case never
    case onScrollDown
    case onScrollUp

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
