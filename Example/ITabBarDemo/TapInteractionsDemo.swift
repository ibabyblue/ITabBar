//
//  TapInteractionsDemo.swift
//  ITabBarDemo
//
//  Created by ibabyblue on 2026/07/17.
//  Copyright © 2026 ibabyblue. All rights reserved.
//


import ITabBar
import SwiftUI

/// The destinations used to demonstrate tap and long-press callbacks.
private enum InteractionTab: String, CaseIterable, Hashable {
    /// The feed destination.
    case feed
    /// The search destination.
    case search
    /// The alerts destination.
    case alerts
    /// The profile destination.
    case profile

    /// The capitalized destination title.
    var title: String { rawValue.capitalized }

    /// The SF Symbols name associated with this destination.
    var icon: String {
        switch self {
        case .feed: "list.bullet.rectangle"
        case .search: "magnifyingglass"
        case .alerts: "bell"
        case .profile: "person"
        }
    }
}

/// Demonstrates selection, same-tab double taps, and selected-tab long presses.
struct TapInteractionsDemo: View {
    /// The caller-owned selected interaction destination.
    @State private var selection: InteractionTab = .feed
    /// The latest interaction message shown by the scene.
    @State private var latestEvent = "Selected Feed"
    /// The number of recognized same-tab double taps.
    @State private var doubleTapCount = 0
    /// The number of recognized long presses on selected tabs.
    @State private var longPressCount = 0

    /// Default item configurations for each interaction destination.
    private let configs = Dictionary(
        uniqueKeysWithValues: InteractionTab.allCases.map { tab in
            (tab, ITabBarItemConfig(icon: tab.icon, title: tab.title))
        }
    )

    /// The interaction tab bar and callbacks that update observable status values.
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

    /// Builds the interaction status page for a destination.
    ///
    /// - Parameter tab: The selected interaction destination.
    /// - Returns: The page showing the latest event and callback counters.
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
