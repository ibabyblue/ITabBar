//
//  _SelectionHelpers.swift
//  ITabBar
//
//  Created by ibabyblue on 2026/05/14.
//  Copyright © 2026 ibabyblue. All rights reserved.
//

/// Resolves a selection against the current tab collection.
///
/// - Parameters:
///   - selection: The candidate selected identifier.
///   - tabs: The currently available identifiers in display order.
/// - Returns: The candidate when valid, the first tab when invalid, or `nil` when `tabs` is empty.
func validatedSelection<Tab: Hashable>(_ selection: Tab, in tabs: [Tab]) -> Tab? {
    guard !tabs.isEmpty else { return nil }
    return tabs.contains(selection) ? selection : tabs.first
}

/// Determines whether a selection binding requires correction.
///
/// - Parameters:
///   - selection: The caller-owned selected identifier.
///   - tabs: The currently available identifiers in display order.
/// - Returns: The first available tab when correction is required; otherwise `nil`.
func selectionCorrection<Tab: Hashable>(_ selection: Tab, in tabs: [Tab]) -> Tab? {
    guard let validated = validatedSelection(selection, in: tabs), validated != selection else {
        return nil
    }
    return validated
}

/// Limits badge text to the three leading extended grapheme clusters.
///
/// - Parameter badge: The optional source badge text.
/// - Returns: The original value when it contains at most three characters, its three-character
///   prefix when longer, or `nil` when the input is `nil`.
func badgeTruncated(_ badge: String?) -> String? {
    guard let badge else { return nil }
    return badge.count > 3 ? String(badge.prefix(3)) : badge
}
