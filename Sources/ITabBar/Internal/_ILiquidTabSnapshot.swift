//
//  _ILiquidTabSnapshot.swift
//  ITabBar
//
//  Created by ibabyblue on 2026/07/16.
//  Copyright © 2026 ibabyblue. All rights reserved.
//

#if os(iOS) && compiler(>=6.2)
import Foundation

@available(iOS 26.0, *)
struct _ILiquidTabSnapshot<Tab: Hashable>: Equatable {
    let tabs: [Tab]
    let configs: [Tab: ILiquidTabBarItemConfig]

    func resolvedSelection(_ selection: Tab) -> Tab? {
        validatedSelection(selection, in: tabs)
    }

    func selectedIndex(for selection: Tab) -> Int? {
        guard let resolvedSelection = resolvedSelection(selection) else {
            return nil
        }
        return tabs.firstIndex(of: resolvedSelection)
    }
}
#endif
