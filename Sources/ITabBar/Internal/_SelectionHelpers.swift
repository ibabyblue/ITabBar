//
//  _SelectionHelpers.swift
//  ITabBar
//
//  Created by ibabyblue on 2026/05/14.
//  Copyright © 2026 ibabyblue. All rights reserved.
//

func validatedSelection<Tab: Hashable>(_ selection: Tab, in tabs: [Tab]) -> Tab? {
    guard !tabs.isEmpty else { return nil }
    return tabs.contains(selection) ? selection : tabs.first
}

func selectionCorrection<Tab: Hashable>(_ selection: Tab, in tabs: [Tab]) -> Tab? {
    guard let validated = validatedSelection(selection, in: tabs), validated != selection else {
        return nil
    }
    return validated
}

func badgeTruncated(_ badge: String?) -> String? {
    guard let badge else { return nil }
    return badge.count > 3 ? String(badge.prefix(3)) : badge
}
