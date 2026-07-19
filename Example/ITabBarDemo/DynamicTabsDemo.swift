//
//  DynamicTabsDemo.swift
//  ITabBarDemo
//
//  Created by ibabyblue on 2026/07/17.
//  Copyright © 2026 ibabyblue. All rights reserved.
//

import ITabBar
import SwiftUI

/// All destinations that can participate in the dynamic tab sequence.
private enum DynamicTab: String, CaseIterable, Hashable {
    /// The home destination.
    case home
    /// The explore destination.
    case explore
    /// The alerts destination.
    case alerts
    /// The profile destination.
    case profile
    /// The optional favorites destination.
    case favorites

    /// The capitalized destination title.
    var title: String { rawValue.capitalized }

    /// The SF Symbols name associated with this destination.
    var icon: String {
        switch self {
        case .home: "house"
        case .explore: "safari"
        case .alerts: "bell"
        case .profile: "person"
        case .favorites: "heart"
        }
    }
}

/// Demonstrates adding, removing, and reordering tabs while preserving valid selection.
struct DynamicTabsDemo: View {
    /// The mutable ordered destinations currently displayed by the tab bar.
    @State private var tabs: [DynamicTab] = [.home, .explore, .alerts, .profile]
    /// The caller-owned selected destination corrected by ``ITabBar`` after removals.
    @State private var selection: DynamicTab = .home

    /// Default item configurations for every destination that may be inserted.
    private let configs = Dictionary(
        uniqueKeysWithValues: DynamicTab.allCases.map { tab in
            (tab, ITabBarItemConfig(icon: tab.icon, selectedIcon: "\(tab.icon).fill", title: tab.title))
        }
    )

    /// The dynamic tab container, current order, and mutation controls.
    var body: some View {
        ITabBar(tabs: tabs, selection: $selection, configs: configs) { tab in
            ScrollView {
                VStack(spacing: 20) {
                    Image(systemName: tab.icon)
                        .font(.system(size: 52))
                        .foregroundStyle(.tint)
                    Text(tab.title)
                        .font(.largeTitle.bold())
                    DemoControlCard {
                        DemoStatusRow(
                            title: "Selection",
                            value: tab.title,
                            accessibilityIdentifier: DemoAccessibility.dynamicSelection
                        )
                        Divider()
                        DemoStatusRow(
                            title: "Order",
                            value: tabs.map(\.title).joined(separator: " · "),
                            accessibilityIdentifier: DemoAccessibility.dynamicOrder
                        )
                        Divider()
                        controls
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.top, 32)
                .padding(.bottom, 100)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
        }
        .navigationTitle("Dynamic Tabs")
        .navigationBarTitleDisplayMode(.inline)
    }

    /// Buttons that remove, insert, reverse, or reset the tab collection.
    private var controls: some View {
        VStack(spacing: 10) {
            Button("Remove selected tab") {
                tabs.removeAll { $0 == selection }
            }
            .buttonStyle(.borderedProminent)
            .disabled(tabs.count <= 1)

            Button(tabs.contains(.favorites) ? "Remove Favorites tab" : "Add Favorites tab") {
                if tabs.contains(.favorites) {
                    tabs.removeAll { $0 == .favorites }
                } else {
                    tabs.append(.favorites)
                }
            }
            .buttonStyle(.bordered)

            Button("Reverse tab order") {
                tabs.reverse()
            }
            .buttonStyle(.bordered)

            Button("Reset tabs") {
                tabs = [.home, .explore, .alerts, .profile]
            }
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity)
    }
}
