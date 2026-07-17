//
//  PlainDemo.swift
//  ITabBarDemo
//
//  Created by ibabyblue on 2026/05/14.
//  Copyright © 2026 ibabyblue. All rights reserved.
//

import SwiftUI
import ITabBar

private enum BasicTab: String, CaseIterable, Hashable {
    case home, explore, messages, profile

    var title: String { rawValue.capitalized }
}

struct BasicPlainDemo: View {
    @State private var selection: BasicTab = .home

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
