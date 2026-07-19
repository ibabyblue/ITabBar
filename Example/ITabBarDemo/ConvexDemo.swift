//
//  ConvexDemo.swift
//  ITabBarDemo
//
//  Created by ibabyblue on 2026/05/14.
//  Copyright © 2026 ibabyblue. All rights reserved.
//

import SwiftUI
import ITabBar

/// The stable destinations displayed around the convex center dome.
private enum ConvexTab: String, CaseIterable, Hashable {
    /// The home destination.
    case home
    /// The explore destination.
    case explore
    /// The messages destination.
    case messages
    /// The profile destination.
    case profile
}

/// Demonstrates a convex tab bar, center action, and live geometry controls.
struct ConvexDemo: View {
    /// The currently selected destination.
    @State private var selection: ConvexTab = .home
    /// The number of center-button taps observed during the scene.
    @State private var centerTapCount = 0

    /// The live clearance between the center button and dome, in points.
    @State private var fabGap: CGFloat = 8
    /// The live distance the button protrudes above the bar, in points.
    @State private var convexProtrusion: CGFloat = 15
    /// The live center-button diameter, in points.
    @State private var fabSize: CGFloat = 52
    /// The live dome shoulder and corner radius, in points.
    @State private var curveRadius: CGFloat = 38

    /// Default item configurations for the convex example.
    private let configs: [ConvexTab: ITabBarItemConfig] = [
        .home:     ITabBarItemConfig(icon: "house",           title: "Home"),
        .explore:  ITabBarItemConfig(icon: "magnifyingglass", title: "Explore"),
        .messages: ITabBarItemConfig(icon: "message",         title: "Messages"),
        .profile:  ITabBarItemConfig(icon: "person",          title: "Profile"),
    ]

    /// A style rebuilt from the current geometry slider values.
    private var style: ITabBarStyle {
        var s = ITabBarStyle()
        s.fabGap = fabGap
        s.convexProtrusion = convexProtrusion
        s.fabSize = fabSize
        s.curveRadius = curveRadius
        return s
    }

    /// The selected destination, status card, geometry controls, and convex tab bar.
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

    /// Sliders that update the convex shape and center button in real time.
    private var controlPanel: some View {
        VStack(spacing: 12) {
            sliderRow(label: "fabGap",           value: $fabGap,           range: 0...30)
            sliderRow(label: "convexProtrusion", value: $convexProtrusion, range: 0...40)
            sliderRow(label: "fabSize",          value: $fabSize,          range: 40...80)
            sliderRow(label: "curveRadius",      value: $curveRadius,      range: 0...60)
        }
    }

    /// Builds a labeled slider with its rounded current value.
    ///
    /// - Parameters:
    ///   - label: The style property name shown beside the slider.
    ///   - value: A binding to the live style value.
    ///   - range: The closed range accepted by the slider.
    /// - Returns: A compact horizontal slider row.
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
