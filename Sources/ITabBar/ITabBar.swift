//
//  ITabBar.swift
//  ITabBar
//
//  Created by ibabyblue on 2026/05/14.
//  Copyright © 2026 ibabyblue. All rights reserved.
//

import SwiftUI

/// Resolved vertical measurements for the tab bar and its bottom safe-area coverage.
struct _TabBarLayoutMetrics {
    /// The height reserved for interactive tab items.
    let itemHeight: CGFloat
    /// The item height plus the device's bottom safe-area inset.
    let totalHeight: CGFloat

    /// Creates layout measurements from the configured item height and current safe area.
    ///
    /// - Parameters:
    ///   - itemHeight: The interactive tab item height, in points.
    ///   - bottomInset: The bottom safe-area inset, in points.
    init(itemHeight: CGFloat, bottomInset: CGFloat) {
        self.itemHeight = itemHeight
        self.totalHeight = itemHeight + bottomInset
    }
}

/// A SwiftUI tab container with configurable contours, items, animations, and a center action.
///
/// The caller owns `selection`. If it is invalid while `tabs` is nonempty, the tab bar corrects
/// it to the first tab. An empty tab list presents no content and leaves the binding unchanged.
public struct ITabBar<Tab: Hashable, Content: View, TabItemView: View & Sendable>: View {
    /// The ordered identifiers displayed by the tab bar.
    private let tabs: [Tab]
    /// The caller-owned identifier of the selected tab.
    @Binding private var selection: Tab
    /// The contour drawn behind the tab items.
    private let shape: ITabBarShape
    /// The visual and layout values applied to the bar.
    private let style: ITabBarStyle
    /// The optional action invoked by the center button on curved bars.
    private let onCenterTap: (() -> Void)?
    /// The builder for the selected tab's main content.
    private let content: (Tab) -> Content
    /// The builder for each standard tab item.
    private let tabItem: (Tab, Bool) -> TabItemView
    /// The optional action invoked after a second tap on the same tab.
    private var doubleTapAction: ((Tab) -> Void)?
    /// The optional action invoked after a long press on the selected tab.
    private var longPressAction: ((Tab) -> Void)?
    /// Item configurations used to resolve animations in the default-item initializer.
    private var configStore: [Tab: ITabBarItemConfig]?

    /// Creates a tab container with a custom item builder.
    ///
    /// - Parameters:
    ///   - tabs: The ordered, unique identifiers to display.
    ///   - selection: A caller-owned binding to the selected identifier.
    ///   - shape: The background contour. The default is ``ITabBarShape/plain``.
    ///   - style: The visual and layout values. The default is ``ITabBarStyle/init()``.
    ///   - onCenterTap: An optional center-button action. The button is shown only for curved shapes.
    ///   - content: A builder for the selected tab's main content.
    ///   - tabItem: A builder that receives each tab and its current selection state.
    public init(
        tabs: [Tab],
        selection: Binding<Tab>,
        shape: ITabBarShape = .plain,
        style: ITabBarStyle = .init(),
        onCenterTap: (() -> Void)? = nil,
        @ViewBuilder content: @escaping (Tab) -> Content,
        @ViewBuilder tabItem: @escaping (Tab, Bool) -> TabItemView
    ) {
        self.tabs = tabs
        self._selection = selection
        self.shape = shape
        self.style = style
        self.onCenterTap = onCenterTap
        self.content = content
        self.tabItem = tabItem
    }

    /// The current selection resolved against the available tabs without mutating the binding.
    private var validSelection: Tab {
        validatedSelection(selection, in: tabs) ?? selection
    }

    /// The vertical floating-action-button offset for the selected bar contour.
    private var fabYOffset: CGFloat {
        switch shape {
        case .plain:   return 0
        case .concave: return style.curveRadius - style.fabSize - style.fabGap
        case .convex:  return -style.convexProtrusion
        }
    }

    /// Replaces an invalid nonempty selection with the first available tab.
    private func correctSelectionIfNeeded() {
        if let corrected = selectionCorrection(selection, in: tabs) {
            selection = corrected
        }
    }

    /// The selected content, tab bar background, items, and optional center button.
    public var body: some View {
        GeometryReader { proxy in
            let bottomInset = proxy.safeAreaInsets.bottom
            let layout = _TabBarLayoutMetrics(itemHeight: style.height, bottomInset: bottomInset)

            ZStack(alignment: .bottom) {
                if let idx = tabs.firstIndex(of: validSelection) {
                    content(tabs[idx])
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }

                ZStack(alignment: .top) {
                    // Background extends through the bottom safe area so the
                    // Home indicator region is covered by the bar.
                    _TabBarBackground(shape: shape, style: style)
                        .frame(height: layout.totalHeight)

                    // Items stay in the original top region (above the safe area).
                    HStack(spacing: style.itemSpacing) {
                        ForEach(Array(tabs.enumerated()), id: \.offset) { idx, tab in
                            if shape != .plain && idx == tabs.count / 2 {
                                Spacer().frame(width: style.fabSize + 16)
                            }
                            let doubleTap = doubleTapAction
                            let longPress = longPressAction
                            _TabBarItem(
                                isSelected: validSelection == tab,
                                animation: configStore?[tab]?.animation ?? .bounce,
                                onTap: { selection = tab },
                                onDoubleTap: doubleTap.map { action in { action(tab) } },
                                onLongPress: longPress.map { action in { action(tab) } }
                            ) {
                                tabItem(tab, validSelection == tab)
                            }
                        }
                    }
                    .padding(.horizontal, 8)
                    .frame(height: layout.itemHeight)

                    if shape != .plain {
                        _FABButton(size: style.fabSize, color: style.fabColor, onTap: onCenterTap)
                            .offset(y: fabYOffset)
                    }
                }
                .frame(height: layout.totalHeight)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea(.container, edges: .bottom)
        }
        .onChange(of: tabs, initial: true) { _, _ in
            correctSelectionIfNeeded()
        }
        .onChange(of: selection) { _, _ in
            correctSelectionIfNeeded()
        }
    }

    /// Registers an action for a second tap on the same tab within the interaction window.
    ///
    /// - Parameter action: A closure that receives the double-tapped tab identifier.
    /// - Returns: A copy of the tab bar with the action installed.
    public func onTabDoubleTap(perform action: @escaping (Tab) -> Void) -> Self {
        var copy = self
        copy.doubleTapAction = action
        return copy
    }

    /// Registers an action for a long press on the currently selected standard tab.
    ///
    /// Long-pressing an unselected tab does not invoke the action or change selection.
    ///
    /// - Parameter action: A closure that receives the long-pressed selected tab identifier.
    /// - Returns: A copy of the tab bar with the action installed.
    public func onTabLongPress(perform action: @escaping (Tab) -> Void) -> Self {
        var copy = self
        copy.longPressAction = action
        return copy
    }
}

// MARK: - Convenience init (default template)

/// Convenience construction that renders ``ITabBarDefaultItemView`` values from configurations.
public extension ITabBar where TabItemView == ITabBarDefaultItemView {
    /// Creates a tab container using the package-provided default item presentation.
    ///
    /// Tabs without a matching configuration display a question-mark icon and an empty title.
    ///
    /// - Parameters:
    ///   - tabs: The ordered, unique identifiers to display.
    ///   - selection: A caller-owned binding to the selected identifier.
    ///   - shape: The background contour. The default is ``ITabBarShape/plain``.
    ///   - style: The visual and layout values. The default is ``ITabBarStyle/init()``.
    ///   - configs: Configurations keyed by tab identifier.
    ///   - onCenterTap: An optional center-button action. The button is shown only for curved shapes.
    ///   - content: A builder for the selected tab's main content.
    init(
        tabs: [Tab],
        selection: Binding<Tab>,
        shape: ITabBarShape = .plain,
        style: ITabBarStyle = .init(),
        configs: [Tab: ITabBarItemConfig],
        onCenterTap: (() -> Void)? = nil,
        @ViewBuilder content: @escaping (Tab) -> Content
    ) {
        self.init(
            tabs: tabs,
            selection: selection,
            shape: shape,
            style: style,
            onCenterTap: onCenterTap,
            content: content,
            tabItem: { tab, isSelected in
                ITabBarDefaultItemView(
                    config: configs[tab] ?? ITabBarItemConfig(icon: "questionmark", title: ""),
                    isSelected: isSelected,
                    style: style
                )
            }
        )
        self.configStore = configs
    }
}
