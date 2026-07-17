//
//  ConvexDemo.swift
//  ITabBarDemo
//
//  Created by ibabyblue on 2026/05/14.
//  Copyright © 2026 ibabyblue. All rights reserved.
//

import SwiftUI
import ITabBar

private enum ConvexTab: String, CaseIterable, Hashable {
    case home, explore, messages, profile
}

struct ConvexDemo: View {
    @State private var selection: ConvexTab = .home
    @State private var centerTapCount = 0

    @State private var fabGap: CGFloat = 8
    @State private var convexProtrusion: CGFloat = 15
    @State private var fabSize: CGFloat = 52
    @State private var curveRadius: CGFloat = 38

    private let configs: [ConvexTab: ITabBarItemConfig] = [
        .home:     ITabBarItemConfig(icon: "house",           title: "Home"),
        .explore:  ITabBarItemConfig(icon: "magnifyingglass", title: "Explore"),
        .messages: ITabBarItemConfig(icon: "message",         title: "Messages"),
        .profile:  ITabBarItemConfig(icon: "person",          title: "Profile"),
    ]

    private var style: ITabBarStyle {
        var s = ITabBarStyle()
        s.fabGap = fabGap
        s.convexProtrusion = convexProtrusion
        s.fabSize = fabSize
        s.curveRadius = curveRadius
        return s
    }

    var body: some View {
        ITabBar(
            tabs: ConvexTab.allCases,
            selection: $selection,
            shape: .convex,
            style: style,
            configs: configs,
            onCenterTap: { centerTapCount += 1 }
        ) { tab in
            VStack(spacing: 24) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 52))
                    .foregroundStyle(.tint)
                Text(tab.rawValue.capitalized)
                    .font(.largeTitle.bold())
                DemoControlCard {
                    DemoStatusRow(
                        title: "Center taps",
                        value: String(centerTapCount),
                        accessibilityIdentifier: DemoAccessibility.convexFABCount
                    )
                    Divider()
                    controlPanel
                }
                .padding(.horizontal, 20)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.bottom, 100)
            .background(Color(.systemGroupedBackground))
        }
        .navigationTitle("Convex + FAB")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var controlPanel: some View {
        VStack(spacing: 12) {
            sliderRow(label: "fabGap",           value: $fabGap,           range: 0...30)
            sliderRow(label: "convexProtrusion", value: $convexProtrusion, range: 0...40)
            sliderRow(label: "fabSize",          value: $fabSize,          range: 40...80)
            sliderRow(label: "curveRadius",      value: $curveRadius,      range: 0...60)
        }
    }

    private func sliderRow(label: String, value: Binding<CGFloat>, range: ClosedRange<CGFloat>) -> some View {
        HStack {
            Text(label).font(.system(size: 12, design: .monospaced)).frame(width: 130, alignment: .leading)
            Slider(value: value, in: range)
            Text(String(format: "%.0f", value.wrappedValue))
                .font(.system(size: 12, design: .monospaced))
                .frame(width: 32, alignment: .trailing)
        }
    }
}
