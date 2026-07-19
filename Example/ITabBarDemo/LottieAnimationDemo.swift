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

/// The bundled one-shot Lottie animations available in the example.
private enum LottieTab: String, CaseIterable, Hashable {
    /// The heart animation.
    case heart
    /// The watermelon animation.
    case watermelon
    /// The toggle-switch animation.
    case switch_
    /// The icon-grid animation.
    case icons

    /// The user-facing tab title.
    var title: String {
        switch self {
        case .heart:      return "Heart"
        case .watermelon: return "Fruit"
        case .switch_:    return "Switch"
        case .icons:      return "Icons"
        }
    }

    /// The resting SF Symbols name displayed outside active playback.
    var staticIcon: String {
        switch self {
        case .heart:      return "heart"
        case .watermelon: return "leaf"
        case .switch_:    return "switch.2"
        case .icons:      return "square.grid.2x2"
        }
    }

    /// The bundled Lottie resource name without its file extension.
    var lottieName: String {
        switch self {
        case .heart:      return "tab_heart"
        case .watermelon: return "tab_watermelon"
        case .switch_:    return "tab_switch"
        case .icons:      return "tab_icons"
        }
    }
}

/// Demonstrates one-shot Lottie playback through a custom tab item animation.
struct LottieAnimationDemo: View {
    /// The currently selected animated destination.
    @State private var selection: LottieTab = .heart

    /// The pink-accented style shared by the Lottie items.
    private let style: ITabBarStyle = {
        var s = ITabBarStyle()
        s.selectedColor = .pink
        s.unselectedColor = .secondary
        s.height = 64
        return s
    }()

    /// Custom animation configurations that create ``LottieTabItem`` values.
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

    /// The selected animation description and Lottie-enabled tab bar.
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

/// A tab item that swaps its resting SF Symbol for bundled one-shot Lottie playback.
private struct LottieTabItem: View {
    /// The animation resource and resting icon represented by this item.
    let tab: LottieTab
    /// The selection and replay token supplied by the custom animation builder.
    let context: ITabBarAnimationContext
    /// The fonts and foreground colors shared with the enclosing tab bar.
    let style: ITabBarStyle

    /// The decoded bundled Lottie animation, or `nil` if the resource cannot be loaded.
    private var lottie: LottieAnimation? { LottieAnimation.named(tab.lottieName) }

    /// The replay container and title for the animated item.
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
