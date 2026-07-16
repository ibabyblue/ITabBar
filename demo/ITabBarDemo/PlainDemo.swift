//
//  PlainDemo.swift
//  ITabBarDemo
//
//  Created by ibabyblue on 2026/05/14.
//  Copyright © 2026 ibabyblue. All rights reserved.
//

import SwiftUI
import ITabBar

private enum PlainTab: String, CaseIterable, Hashable {
    case home, explore, messages, profile
}

struct PlainDemo: View {
    @State private var selection: PlainTab = .home
    @Environment(\.dismiss) private var dismiss

    private let configs: [PlainTab: ITabBarItemConfig] = [
        .home:     ITabBarItemConfig(icon: "house",           title: "Home"),
        .explore:  ITabBarItemConfig(icon: "magnifyingglass", title: "Explore"),
        .messages: ITabBarItemConfig(icon: "message",         title: "Messages", badge: "3"),
        .profile:  ITabBarItemConfig(icon: "person",          title: "Profile"),
    ]

    var body: some View {
        ITabBar(
            tabs: PlainTab.allCases,
            selection: $selection,
            shape: .plain,
            configs: configs
        ) { tab in
            pageContent(tab)
                .ignoresSafeArea()
        }
        .onTabDoubleTap { tab in
            print("[PlainDemo] double tap: \(tab)")
        }
        .onTabLongPress { tab in
            print("[PlainDemo] long press: \(tab)")
        }
        .overlay(alignment: .topLeading) {
            Button("Close") { dismiss() }
                .padding()
        }
    }

    @ViewBuilder
    private func pageContent(_ tab: PlainTab) -> some View {
        Color.clear.overlay(
            Text(tab.rawValue.capitalized)
                .font(.largeTitle.bold())
        )
    }
}
