//
//  TapInteractionsDemo.swift
//  ITabBarDemo
//
//  Created by ibabyblue on 2026/07/17.
//  Copyright © 2026 ibabyblue. All rights reserved.
//


import ITabBar
import SwiftUI

private enum InteractionTab: String, CaseIterable, Hashable {
    case feed, search, alerts, profile

    var title: String { rawValue.capitalized }

    var icon: String {
        switch self {
        case .feed: "list.bullet.rectangle"
        case .search: "magnifyingglass"
        case .alerts: "bell"
        case .profile: "person"
        }
    }
}

struct TapInteractionsDemo: View {
    @State private var selection: InteractionTab = .feed
    @State private var latestEvent = "Selected Feed"
    @State private var doubleTapCount = 0
    @State private var longPressCount = 0

    private let configs = Dictionary(
        uniqueKeysWithValues: InteractionTab.allCases.map { tab in
            (tab, ITabBarItemConfig(icon: tab.icon, title: tab.title))
        }
    )

    var body: some View {
        ITabBar(
            tabs: InteractionTab.allCases,
            selection: $selection,
            configs: configs
        ) { tab in
            pageContent(tab)
        }
        .onTabDoubleTap { tab in
            doubleTapCount += 1
            latestEvent = "Double-tapped \(tab.title)"
        }
        .onTabLongPress { tab in
            longPressCount += 1
            latestEvent = "Long-pressed \(tab.title)"
        }
        .onChange(of: selection) { _, newValue in
            latestEvent = "Selected \(newValue.title)"
        }
        .navigationTitle("Tap Interactions")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func pageContent(_ tab: InteractionTab) -> some View {
        VStack(spacing: 24) {
            Image(systemName: tab.icon)
                .font(.system(size: 52))
                .foregroundStyle(.tint)
            Text(tab.title)
                .font(.largeTitle.bold())
            DemoControlCard {
                DemoStatusRow(
                    title: "Latest event",
                    value: latestEvent,
                    accessibilityIdentifier: DemoAccessibility.tapEvent
                )
                Divider()
                DemoStatusRow(
                    title: "Double taps",
                    value: String(doubleTapCount),
                    accessibilityIdentifier: DemoAccessibility.tapDoubleCount
                )
                Divider()
                DemoStatusRow(
                    title: "Long presses",
                    value: String(longPressCount),
                    accessibilityIdentifier: DemoAccessibility.tapLongPressCount
                )
            }
            .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}
