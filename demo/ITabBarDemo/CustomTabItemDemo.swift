//
//  CustomTabItemDemo.swift
//  ITabBarDemo
//
//  Created by ibabyblue on 2026/07/17.
//  Copyright © 2026 ibabyblue. All rights reserved.
//

import ITabBar
import SwiftUI

private enum CustomItemTab: String, CaseIterable, Hashable {
    case browse, library, downloads

    var title: String { rawValue.capitalized }

    var icon: String {
        switch self {
        case .browse: "safari"
        case .library: "books.vertical"
        case .downloads: "arrow.down.circle"
        }
    }
}

struct CustomTabItemDemo: View {
    @State private var selection: CustomItemTab = .browse

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

private struct CustomTabItem: View, Sendable {
    let tab: CustomItemTab
    let isSelected: Bool

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
