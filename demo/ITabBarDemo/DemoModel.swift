//
//  DemoModel.swift
//  ITabBarDemo
//
//  Created by ibabyblue on 2026/07/17.
//  Copyright © 2026 ibabyblue. All rights reserved.
//

import SwiftUI

enum DemoSection: String, CaseIterable, Identifiable {
    case essentials
    case customization
    case iOS26

    var id: Self { self }

    var title: String {
        switch self {
        case .essentials: "ITabBar Essentials"
        case .customization: "Customization"
        case .iOS26: "iOS 26"
        }
    }
}

enum DemoExample: String, CaseIterable, Identifiable {
    case basicPlain
    case tapInteractions
    case concaveFAB
    case convexFAB
    case dynamicTabs
    case customStyling
    case customTabItem
    case builtInAnimations
    case lottieAnimation
    case nativeLiquidGlass

    var id: Self { self }
    var section: DemoSection {
        switch self {
        case .customStyling, .customTabItem, .builtInAnimations, .lottieAnimation: .customization
        case .nativeLiquidGlass: .iOS26
        default: .essentials
        }
    }

    var title: String {
        switch self {
        case .basicPlain: "Basic Plain"
        case .tapInteractions: "Tap Interactions"
        case .concaveFAB: "Concave + FAB"
        case .convexFAB: "Convex + FAB"
        case .customStyling: "Custom Styling"
        case .customTabItem: "Custom Tab Item"
        case .builtInAnimations: "Built-in Animations"
        case .lottieAnimation: "Lottie Animation"
        case .dynamicTabs: "Dynamic Tabs"
        case .nativeLiquidGlass: "Native Liquid Glass"
        }
    }

    var summary: String {
        switch self {
        case .basicPlain:
            "Default icons, selected images, titles, badge, and selection."
        case .tapInteractions:
            "Visible selection, double-tap, and long-press callbacks."
        case .concaveFAB:
            "A recessed center action with live geometry controls."
        case .convexFAB:
            "A raised center action with live geometry controls."
        case .customStyling:
            "Colors, typography, height, material, spacing, and badges."
        case .customTabItem:
            "Replace the default item view with your own SwiftUI layout."
        case .builtInAnimations:
            "Compare bounce, wiggle, pop, and no item animation."
        case .lottieAnimation:
            "Play bundled Lottie artwork through the custom animation API."
        case .dynamicTabs:
            "Add, remove, and reorder tabs while selection stays valid."
        case .nativeLiquidGlass:
            "The native iOS 26 tab bar, Liquid Glass lens, and minimize behavior."
        }
    }

    var systemImage: String {
        switch self {
        case .basicPlain: "rectangle.bottomthird.inset.filled"
        case .tapInteractions: "hand.tap"
        case .concaveFAB: "arrow.down.circle"
        case .convexFAB: "arrow.up.circle"
        case .customStyling: "paintpalette"
        case .customTabItem: "rectangle.3.group"
        case .builtInAnimations: "sparkles"
        case .lottieAnimation: "play.square.stack"
        case .dynamicTabs: "arrow.left.arrow.right.square"
        case .nativeLiquidGlass: "drop.halffull"
        }
    }

    var accessibilityIdentifier: String {
        "demo.example.\(rawValue)"
    }

    static var availableExamples: [Self] {
#if compiler(>=6.2)
        if #available(iOS 26.0, *) {
            allCases
        } else {
            allCases.filter { $0 != .nativeLiquidGlass }
        }
#else
        allCases.filter { $0 != .nativeLiquidGlass }
#endif
    }
}

enum DemoAccessibility {
    static let basicSelection = "demo.basic.selection"
    static let tapEvent = "demo.tap.event"
    static let tapDoubleCount = "demo.tap.doubleCount"
    static let tapLongPressCount = "demo.tap.longPressCount"
    static let concaveFABCount = "demo.concave.fabCount"
    static let convexFABCount = "demo.convex.fabCount"
    static let customItemSelection = "demo.customItem.selection"
    static let dynamicSelection = "demo.dynamic.selection"
    static let dynamicOrder = "demo.dynamic.order"
    static let liquidSelection = "demo.liquid.selection"
    static let liquidOrder = "demo.liquid.order"
    static let liquidDoubleCount = "demo.liquid.doubleCount"
}
