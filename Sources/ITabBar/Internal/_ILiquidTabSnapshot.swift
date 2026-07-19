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
/// An equatable value snapshot of native liquid tab identities and configurations.
struct _ILiquidTabSnapshot<Tab: Hashable>: Equatable {
    /// The ordered identifiers represented by the snapshot.
    let tabs: [Tab]
    /// Native item configurations keyed by identifier.
    let configs: [Tab: ILiquidTabBarItemConfig]

    /// Resolves a candidate selection against the snapshot's identifiers.
    ///
    /// - Parameter selection: The candidate selected identifier.
    /// - Returns: The candidate when valid, the first tab when invalid, or `nil` for an empty snapshot.
    func resolvedSelection(_ selection: Tab) -> Tab? {
        validatedSelection(selection, in: tabs)
    }

    /// Finds the index represented by a resolved selection.
    ///
    /// - Parameter selection: The candidate selected identifier.
    /// - Returns: The selected index, or `nil` when the snapshot has no tabs.
    func selectedIndex(for selection: Tab) -> Int? {
        guard let resolvedSelection = resolvedSelection(selection) else {
            return nil
        }
        return tabs.firstIndex(of: resolvedSelection)
    }
}
#endif
