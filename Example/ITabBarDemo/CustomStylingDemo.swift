//
//  CustomStylingDemo.swift
//  ITabBarDemo
//
//  Created by ibabyblue on 2026/07/17.
//  Copyright © 2026 ibabyblue. All rights reserved.
//

import ITabBar
import SwiftUI

/// The destinations used to demonstrate style customization.
private enum StyledTab: String, CaseIterable, Hashable {
    /// The overview destination.
    case overview
    /// The favorites destination.
    case favorites
    /// The inbox destination.
    case inbox
    /// The account destination.
    case account

    /// The capitalized destination title.
    var title: String { rawValue.capitalized }
}

/// Demonstrates colors, fonts, dimensions, spacing, and badge styling.
struct CustomStylingDemo: View {
    /// The currently selected styled destination.
    @State private var selection: StyledTab = .overview

    /// The customized style applied to the example tab bar.
    private let style: ITabBarStyle = {
        var style = ITabBarStyle()
        style.selectedColor = .indigo
        style.unselectedColor = .gray
        style.selectedFont = .system(size: 11, weight: .bold, design: .rounded)
        style.unselectedFont = .system(size: 10, weight: .medium, design: .rounded)
        style.backgroundColor = Color.indigo.opacity(0.12)
        style.height = 68
        style.itemSpacing = 6
        style.badgeColor = .orange
        return style
    }()

    /// Icons, titles, and badge content for the styled destinations.
    private let configs: [StyledTab: ITabBarItemConfig] = [
        .overview: .init(icon: "chart.bar", selectedIcon: "chart.bar.fill", title: "Overview"),
        .favorites: .init(icon: "heart", selectedIcon: "heart.fill", title: "Favorites"),
        .inbox: .init(icon: "tray", selectedIcon: "tray.fill", title: "Inbox", badge: "9"),
        .account: .init(icon: "person.crop.circle", selectedIcon: "person.crop.circle.fill", title: "Account"),
    ]

    /// The selected destination and fully customized tab bar.
    var body: some View {
        ITabBar(tabs: StyledTab.allCases, selection: $selection, style: style, configs: configs) { tab in
            VStack(spacing: 20) {
                Image(systemName: configs[tab]?.selectedIcon ?? "paintpalette.fill")
                    .font(.system(size: 52))
                    .foregroundStyle(.indigo)
                Text(tab.title)
                    .font(.largeTitle.bold())
                Text("Every visible value in this tab bar comes from ITabBarStyle or ITabBarItemConfig.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
        }
        .navigationTitle("Custom Styling")
        .navigationBarTitleDisplayMode(.inline)
    }
}
