//
//  AnimationDemo.swift
//  ITabBarDemo
//
//  Created by ibabyblue on 2026/05/14.
//  Copyright © 2026 ibabyblue. All rights reserved.
//

import SwiftUI
import ITabBar

/// The built-in animation choices demonstrated by the catalog scene.
private enum AnimTab: String, CaseIterable, Hashable {
    /// Demonstrates the vertical spring bounce.
    case bounce
    /// Demonstrates the rotational wiggle.
    case wiggle
    /// Demonstrates the scale pop.
    case pop
    /// Demonstrates an item without a selection animation.
    case none_
    /// The user-facing animation name.
    var title: String { self == .none_ ? "None" : rawValue.capitalized }
    /// The package animation represented by this tab.
    var animation: ITabBarAnimation {
        switch self {
        case .bounce: return .bounce
        case .wiggle: return .wiggle
        case .pop:    return .pop
        case .none_:  return .none
        }
    }
}

/// Demonstrates every built-in ``ITabBarAnimation`` option in one plain tab bar.
struct AnimationDemo: View {
    /// The animation example currently selected by the user.
    @State private var selection: AnimTab = .bounce

    /// The orange-accented style shared by all animation items.
    private let style: ITabBarStyle = {
        var s = ITabBarStyle()
        s.selectedColor = .orange
        s.fabColor = .orange
        return s
    }()

    /// Item configurations mapped to their corresponding animation options.
    private var configs: [AnimTab: ITabBarItemConfig] {
        Dictionary(uniqueKeysWithValues: AnimTab.allCases.map { tab in
            (tab, ITabBarItemConfig(
                icon: "star",
                selectedIcon: "star.fill",
                title: tab.title,
                animation: tab.animation
            ))
        })
    }

    /// The animation sample page and its plain tab bar selector.
    var body: some View {
        ITabBar(
            tabs: AnimTab.allCases,
            selection: $selection,
            shape: .plain,
            style: style,
            configs: configs,
            onCenterTap: nil
        ) { tab in
            VStack(spacing: 12) {
                Image(systemName: "star.fill")
                    .font(.system(size: 52))
                    .foregroundStyle(.orange)
                Text(tab.title).font(.largeTitle.bold())
                Text("Tap the \"\(tab.title)\" tab below to see its animation")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
        }
        .navigationTitle("Built-in Animations")
        .navigationBarTitleDisplayMode(.inline)
    }
}
