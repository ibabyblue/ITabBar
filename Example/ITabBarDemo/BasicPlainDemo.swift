//
//  PlainDemo.swift
//  ITabBarDemo
//
//  Created by ibabyblue on 2026/05/14.
//  Copyright © 2026 ibabyblue. All rights reserved.
//

import SwiftUI
import ITabBar

/// The stable tab identities used by the basic plain example.
private enum BasicTab: String, CaseIterable, Hashable {
    /// The home destination.
    case home
    /// The explore destination.
    case explore
    /// The messages destination.
    case messages
    /// The profile destination.
    case profile

    /// The capitalized destination title.
    var title: String { rawValue.capitalized }
}

/// Demonstrates the default plain tab bar, selected icons, and a badge.
struct BasicPlainDemo: View {
    /// The caller-owned selected destination.
    @State private var selection: BasicTab = .home

    /// Default-item configurations for each destination.
    private let configs: [BasicTab: ITabBarItemConfig] = [
        .home: ITabBarItemConfig(icon: "house", selectedIcon: "house.fill", title: "Home"),
        .explore: ITabBarItemConfig(icon: "safari", selectedIcon: "safari.fill", title: "Explore"),
        .messages: ITabBarItemConfig(
            icon: "message",
            selectedIcon: "message.fill",
            title: "Messages",
            badge: "3"
        ),
        .profile: ITabBarItemConfig(icon: "person", selectedIcon: "person.fill", title: "Profile"),
    ]

    /// The selected page and its default plain tab bar.
    var body: some View {
        ITabBar(
            tabs: BasicTab.allCases,
            selection: $selection,
            shape: .plain,
            configs: configs
        ) { tab in
            pageContent(tab)
        }
        .navigationTitle("Basic Plain")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    /// Builds the content and observable selection status for a destination.
    ///
    /// - Parameter tab: The selected basic tab.
    /// - Returns: The page associated with `tab`.
    private func pageContent(_ tab: BasicTab) -> some View {
        VStack(spacing: 24) {
            Image(systemName: configs[tab]?.selectedIcon ?? configs[tab]?.icon ?? "questionmark")
                .font(.system(size: 52))
                .foregroundStyle(.tint)
            Text(tab.title)
                .font(.largeTitle.bold())
            DemoControlCard {
                DemoStatusRow(
                    title: "Selection",
                    value: tab.title,
                    accessibilityIdentifier: DemoAccessibility.basicSelection
                )
            }
            .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}
