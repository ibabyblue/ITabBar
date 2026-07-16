//
//  AnimationDemo.swift
//  ITabBarDemo
//
//  Created by ibabyblue on 2026/05/14.
//  Copyright © 2026 ibabyblue. All rights reserved.
//

import SwiftUI
import ITabBar

private enum AnimTab: String, CaseIterable, Hashable {
    case bounce, wiggle, pop, none_
    var title: String { self == .none_ ? "None" : rawValue.capitalized }
    var animation: ITabBarAnimation {
        switch self {
        case .bounce: return .bounce
        case .wiggle: return .wiggle
        case .pop:    return .pop
        case .none_:  return .none
        }
    }
}

struct AnimationDemo: View {
    @State private var selection: AnimTab = .bounce
    @Environment(\.dismiss) private var dismiss

    private let style: ITabBarStyle = {
        var s = ITabBarStyle()
        s.selectedColor = .orange
        s.fabColor = .orange
        return s
    }()

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

    var body: some View {
        ITabBar(
            tabs: AnimTab.allCases,
            selection: $selection,
            shape: .concave,
            style: style,
            configs: configs,
            onCenterTap: nil
        ) { tab in
            VStack(spacing: 12) {
                Text(tab.title).font(.largeTitle.bold())
                Text("Tap the \"\(tab.title)\" tab below to see its animation")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            .ignoresSafeArea()
        }
        .overlay(alignment: .topLeading) {
            Button("Close") { dismiss() }.padding()
        }
    }
}
