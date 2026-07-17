//
//  CustomStylingDemo.swift
//  ITabBarDemo
//
//  Created by ibabyblue on 2026/07/17.
//  Copyright © 2026 ibabyblue. All rights reserved.
//

import ITabBar
import SwiftUI

private enum StyledTab: String, CaseIterable, Hashable {
    case overview, favorites, inbox, account

    var title: String { rawValue.capitalized }
}

struct CustomStylingDemo: View {
    @State private var selection: StyledTab = .overview

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

    private let configs: [StyledTab: ITabBarItemConfig] = [
        .overview: .init(icon: "chart.bar", selectedIcon: "chart.bar.fill", title: "Overview"),
        .favorites: .init(icon: "heart", selectedIcon: "heart.fill", title: "Favorites"),
        .inbox: .init(icon: "tray", selectedIcon: "tray.fill", title: "Inbox", badge: "9"),
        .account: .init(icon: "person.crop.circle", selectedIcon: "person.crop.circle.fill", title: "Account"),
    ]

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
