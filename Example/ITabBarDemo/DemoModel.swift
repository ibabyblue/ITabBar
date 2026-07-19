//
//  DemoModel.swift
//  ITabBarDemo
//
//  Created by ibabyblue on 2026/07/17.
//  Copyright © 2026 ibabyblue. All rights reserved.
//

import SwiftUI

/// The top-level groups used to organize the example catalog.
enum DemoSection: String, CaseIterable, Identifiable {
    /// Core selection, shape, interaction, and dynamic-data examples.
    case essentials
    /// Visual, item-builder, and animation customization examples.
    case customization
    /// Examples available only with the iOS 26 SDK and runtime.
    case iOS26

    /// The stable identity of this section.
    var id: Self { self }

    /// The user-facing catalog section title.
    var title: String {
        switch self {
        case .essentials: "ITabBar Essentials"
        case .customization: "Customization"
        case .iOS26: "iOS 26"
        }
    }
}

/// A runnable integration scenario available from the example catalog.
enum DemoExample: String, CaseIterable, Identifiable {
    /// Default plain bar, selected icons, title, and badge behavior.
    case basicPlain
    /// Double-tap and selected-tab long-press callbacks.
    case tapInteractions
    /// A concave center cutout with a floating action button.
    case concaveFAB
    /// A convex center dome with a floating action button.
    case convexFAB
    /// Runtime insertion, removal, reordering, and selection correction.
    case dynamicTabs
    /// Custom colors, fonts, dimensions, material, spacing, and badge appearance.
    case customStyling
    /// A consumer-supplied SwiftUI tab item hierarchy.
    case customTabItem
    /// The package's bounce, wiggle, pop, and disabled animations.
    case builtInAnimations
    /// One-shot bundled Lottie playback through the custom animation API.
    case lottieAnimation
    /// The native iOS 26 Liquid Glass tab bar integration.
    case nativeLiquidGlass

    /// The stable identity of this example.
    var id: Self { self }
    /// The catalog section containing this example.
    var section: DemoSection {
        switch self {
        case .customStyling, .customTabItem, .builtInAnimations, .lottieAnimation: .customization
        case .nativeLiquidGlass: .iOS26
        default: .essentials
        }
    }

    /// The user-facing navigation title.
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

    /// A concise description shown beneath the catalog title.
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

    /// The SF Symbols name shown in the catalog row.
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

    /// The stable UI-test identifier assigned to this catalog row.
    var accessibilityIdentifier: String {
        "demo.example.\(rawValue)"
    }

    /// The examples supported by the active Swift compiler and runtime.
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

/// Stable accessibility identifiers shared by the example scenes and UI tests.
enum DemoAccessibility {
    /// The selected value in the basic plain example.
    static let basicSelection = "demo.basic.selection"
    /// The latest event in the tap interaction example.
    static let tapEvent = "demo.tap.event"
    /// The double-tap count in the tap interaction example.
    static let tapDoubleCount = "demo.tap.doubleCount"
    /// The selected-tab long-press count in the tap interaction example.
    static let tapLongPressCount = "demo.tap.longPressCount"
    /// The center-button tap count in the concave example.
    static let concaveFABCount = "demo.concave.fabCount"
    /// The center-button tap count in the convex example.
    static let convexFABCount = "demo.convex.fabCount"
    /// The selected value in the custom-item example.
    static let customItemSelection = "demo.customItem.selection"
    /// The current selection in the dynamic-tabs example.
    static let dynamicSelection = "demo.dynamic.selection"
    /// The current ordered tab list in the dynamic-tabs example.
    static let dynamicOrder = "demo.dynamic.order"
    /// The current selection in the native liquid example.
    static let liquidSelection = "demo.liquid.selection"
    /// The current ordered tab list in the native liquid example.
    static let liquidOrder = "demo.liquid.order"
    /// The recognized double-tap count in the native liquid example.
    static let liquidDoubleCount = "demo.liquid.doubleCount"
}
