//
//  CustomTabItemDemo.swift
//  ITabBarDemo
//
//  Created by ibabyblue on 2026/07/17.
//  Copyright © 2026 ibabyblue. All rights reserved.
//

import ITabBar
import SwiftUI

/// The destinations rendered by the custom capsule item builder.
private enum CustomItemTab: String, CaseIterable, Hashable {
    /// The browsing destination.
    case browse
    /// The library destination.
    case library
    /// The downloads destination.
    case downloads

    /// The capitalized destination title.
    var title: String { rawValue.capitalized }

    /// The SF Symbols name associated with this destination.
    var icon: String {
        switch self {
        case .browse: "safari"
        case .library: "books.vertical"
        case .downloads: "arrow.down.circle"
        }
    }
}

/// Demonstrates the custom `tabItem` initializer instead of default configurations.
struct CustomTabItemDemo: View {
    /// The currently selected custom-item destination.
    @State private var selection: CustomItemTab = .browse

    /// The selected destination and custom capsule tab items.
    var body: some View {
        ITabBar(tabs: CustomItemTab.allCases, selection: $selection) { tab in
            VStack(spacing: 24) {
                Text(tab.title)
                    .font(.largeTitle.bold())
                DemoControlCard {
                    DemoStatusRow(
                        title: "Selection",
                        value: tab.title,
                        accessibilityIdentifier: DemoAccessibility.customItemSelection
                    )
                }
                .padding(.horizontal, 24)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
        } tabItem: { tab, isSelected in
            CustomTabItem(tab: tab, isSelected: isSelected)
        }
        .navigationTitle("Custom Tab Item")
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// A capsule-shaped tab item that expands its selected presentation.
private struct CustomTabItem: View, Sendable {
    /// The destination represented by this item.
    let tab: CustomItemTab
    /// Whether the item currently represents the selected destination.
    let isSelected: Bool

    /// The adaptive capsule content for the current selection state.
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: tab.icon)
            if isSelected {
                Text(tab.title)
                    .font(.caption.bold())
            } else {
                Text(tab.title)
                    .font(.caption2)
            }
        }
        .foregroundStyle(isSelected ? Color.white : Color.secondary)
        .padding(.horizontal, isSelected ? 14 : 8)
        .frame(height: 36)
        .background(isSelected ? Color.indigo : Color.clear, in: Capsule())
        .animation(.snappy, value: isSelected)
    }
}
