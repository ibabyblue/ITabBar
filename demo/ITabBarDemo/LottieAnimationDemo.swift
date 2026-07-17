//
//  LottieAnimationDemo.swift
//  ITabBarDemo
//
//  Created by ibabyblue on 2026/05/18.
//  Copyright © 2026 ibabyblue. All rights reserved.
//

import SwiftUI
import ITabBar
import Lottie

// Usage pattern shown here:
//   1. Each tab's `.animation = .custom { ctx in ... }` returns an ITabBarTapPlayView.
//   2. The library handles all state — default view ↔ active view, re-tap restart,
//      cross-tab cancellation, duration-based revert.
//   3. The consumer only provides:
//        - default view (static icon at rest)
//        - active view (Lottie / SwiftUI animation that plays once)
//        - duration (how long the active view stays before snapping back)

private enum LottieTab: String, CaseIterable, Hashable {
    case heart, watermelon, switch_, icons

    var title: String {
        switch self {
        case .heart:      return "Heart"
        case .watermelon: return "Fruit"
        case .switch_:    return "Switch"
        case .icons:      return "Icons"
        }
    }

    var staticIcon: String {
        switch self {
        case .heart:      return "heart"
        case .watermelon: return "leaf"
        case .switch_:    return "switch.2"
        case .icons:      return "square.grid.2x2"
        }
    }

    var lottieName: String {
        switch self {
        case .heart:      return "tab_heart"
        case .watermelon: return "tab_watermelon"
        case .switch_:    return "tab_switch"
        case .icons:      return "tab_icons"
        }
    }
}

struct LottieAnimationDemo: View {
    @State private var selection: LottieTab = .heart

    private let style: ITabBarStyle = {
        var s = ITabBarStyle()
        s.selectedColor = .pink
        s.unselectedColor = .secondary
        s.height = 64
        return s
    }()

    private var configs: [LottieTab: ITabBarItemConfig] {
        Dictionary(uniqueKeysWithValues: LottieTab.allCases.map { tab in
            (tab, ITabBarItemConfig(
                icon: tab.staticIcon,
                title: tab.title,
                animation: .custom { ctx in
                    AnyView(LottieTabItem(tab: tab, context: ctx, style: style))
                }
            ))
        })
    }

    var body: some View {
        ITabBar(
            tabs: LottieTab.allCases,
            selection: $selection,
            shape: .plain,
            style: style,
            configs: configs,
            onCenterTap: nil
        ) { tab in
            VStack(spacing: 12) {
                Image(systemName: tab.staticIcon)
                    .font(.system(size: 52))
                    .foregroundStyle(.pink)
                Text(tab.title).font(.largeTitle.bold())
                Text("Tap any tab below — the static icon swaps to a Lottie animation, plays once, then snaps back.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
        }
        .navigationTitle("Lottie Animation")
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// One tab item: static SF Symbol by default, Lottie on tap — fully driven by ITabBarTapPlayView.
private struct LottieTabItem: View {
    let tab: LottieTab
    let context: ITabBarAnimationContext
    let style: ITabBarStyle

    private var lottie: LottieAnimation? { LottieAnimation.named(tab.lottieName) }

    var body: some View {
        VStack(spacing: 2) {
            ITabBarTapPlayView(
                context: context,
                duration: lottie?.duration ?? 1.0
            ) {
                Image(systemName: tab.staticIcon)
                    .font(.system(size: 22))
                    .foregroundStyle(context.isSelected ? style.selectedColor : style.unselectedColor)
            } active: {
                if let lottie {
                    LottieView(animation: lottie)
                        .resizable()
                        .playbackMode(.playing(.fromProgress(0, toProgress: 1, loopMode: .playOnce)))
                }
            }
            .frame(width: 36, height: 36)

            Text(tab.title)
                .font(context.isSelected ? style.selectedFont : style.unselectedFont)
                .foregroundStyle(context.isSelected ? style.selectedColor : style.unselectedColor)
        }
    }
}
