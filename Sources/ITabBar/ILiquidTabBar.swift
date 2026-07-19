//
//  ILiquidTabBar.swift
//  ITabBar
//
//  Created by ibabyblue on 2026/07/16.
//  Copyright © 2026 ibabyblue. All rights reserved.
//

#if os(iOS) && compiler(>=6.2)
import SwiftUI
import UIKit

/// A native iOS 26 tab bar whose Liquid Glass appearance and transitions are
/// fully managed by `UITabBarController`.
@available(iOS 26.0, *)
public struct ILiquidTabBar<Tab: Hashable, Content: View>: View {
    /// The ordered identifiers represented by native tab bar items.
    private let tabs: [Tab]
    /// The caller-owned identifier of the selected tab.
    @Binding private var selection: Tab
    /// Native item configurations keyed by tab identifier.
    private let configs: [Tab: ILiquidTabBarItemConfig]
    /// The native scrolling policy that controls tab bar minimization.
    private let minimizeBehavior: ILiquidTabBarMinimizeBehavior
    /// The builder for each tab's hosted SwiftUI content.
    private let content: (Tab) -> Content
    /// The optional action invoked after a second selection of the same tab.
    private var doubleTapAction: ((Tab) -> Void)?

    /// Creates a native iOS 26 tab container.
    ///
    /// The caller owns `selection`. If it is invalid while `tabs` is nonempty, the component
    /// corrects it to the first tab. An empty tab list leaves the binding unchanged.
    ///
    /// - Parameters:
    ///   - tabs: The ordered, unique identifiers represented by native tab bar items.
    ///   - selection: A caller-owned binding to the selected identifier.
    ///   - configs: Native item configurations keyed by tab identifier.
    ///   - minimizeBehavior: The iOS 26 minimization policy. The default is `.automatic`.
    ///   - content: A builder for each tab's hosted SwiftUI content.
    public init(
        tabs: [Tab],
        selection: Binding<Tab>,
        configs: [Tab: ILiquidTabBarItemConfig],
        minimizeBehavior: ILiquidTabBarMinimizeBehavior = .automatic,
        @ViewBuilder content: @escaping (Tab) -> Content
    ) {
        self.tabs = tabs
        self._selection = selection
        self.configs = configs
        self.minimizeBehavior = minimizeBehavior
        self.content = content
    }

    /// The native tab bar controller bridge and selection-correction observers.
    public var body: some View {
        _ILiquidTabControllerBridge(
            tabs: tabs,
            selection: $selection,
            configs: configs,
            minimizeBehavior: minimizeBehavior,
            doubleTapAction: doubleTapAction,
            content: content
        )
        .onChange(of: tabs, initial: true) { _, _ in
            correctSelectionIfNeeded()
        }
        .onChange(of: selection) { _, _ in
            correctSelectionIfNeeded()
        }
    }

    /// Replaces an invalid nonempty selection with the first available tab.
    private func correctSelectionIfNeeded() {
        if let correctedSelection = selectionCorrection(selection, in: tabs) {
            selection = correctedSelection
        }
    }

    /// Registers an action for a second selection of the same native tab within the interaction window.
    ///
    /// - Parameter action: A closure that receives the double-selected tab identifier.
    /// - Returns: A copy of the liquid tab bar with the action installed.
    public func onTabDoubleTap(perform action: @escaping (Tab) -> Void) -> Self {
        var copy = self
        copy.doubleTapAction = action
        return copy
    }
}

@available(iOS 26.0, *)
/// A SwiftUI representable that owns the package's native tab bar controller.
private struct _ILiquidTabControllerBridge<Tab: Hashable, Content: View>: UIViewControllerRepresentable {
    /// The ordered identifiers represented by native controllers.
    let tabs: [Tab]
    /// The caller-owned selection binding.
    @Binding var selection: Tab
    /// Native item configurations keyed by tab identifier.
    let configs: [Tab: ILiquidTabBarItemConfig]
    /// The native scrolling minimization policy.
    let minimizeBehavior: ILiquidTabBarMinimizeBehavior
    /// The optional same-tab double-selection callback.
    let doubleTapAction: ((Tab) -> Void)?
    /// The builder that supplies each hosted SwiftUI root view.
    let content: (Tab) -> Content

    /// Creates the coordinator that synchronizes SwiftUI state with UIKit.
    ///
    /// - Returns: A coordinator initialized with the current selection binding.
    func makeCoordinator() -> Coordinator {
        Coordinator(selection: $selection)
    }

    /// Creates and initially synchronizes the native tab bar controller.
    ///
    /// - Parameter context: The representable context containing the coordinator.
    /// - Returns: A configured `UITabBarController`.
    func makeUIViewController(context: Context) -> UITabBarController {
        let controller = UITabBarController()
        controller.delegate = context.coordinator
        context.coordinator.synchronize(
            controller: controller,
            tabs: tabs,
            selection: selection,
            configs: configs,
            minimizeBehavior: minimizeBehavior,
            doubleTapAction: doubleTapAction,
            content: content
        )
        return controller
    }

    /// Synchronizes dynamic tabs, content, configuration, and selection into UIKit.
    ///
    /// - Parameters:
    ///   - controller: The existing native tab bar controller.
    ///   - context: The representable context containing the coordinator.
    func updateUIViewController(_ controller: UITabBarController, context: Context) {
        context.coordinator.selection = $selection
        context.coordinator.synchronize(
            controller: controller,
            tabs: tabs,
            selection: selection,
            configs: configs,
            minimizeBehavior: minimizeBehavior,
            doubleTapAction: doubleTapAction,
            content: content
        )
    }

    @MainActor
    /// Coordinates dynamic controller reuse, selection binding, and double-tap recognition.
    final class Coordinator: NSObject, UITabBarControllerDelegate {
        /// The current caller-owned selection binding.
        var selection: Binding<Tab>

        /// The ordered tabs represented by the controller's current children.
        private var tabs: [Tab] = []
        /// Reusable hosting controllers keyed by stable tab identity.
        private var hostingControllers: [Tab: UIHostingController<Content>] = [:]
        /// The optional same-tab double-selection callback.
        private var doubleTapAction: ((Tab) -> Void)?
        /// Stateful timing used to distinguish a native double selection.
        private var interactionState = _ILiquidTabInteractionState<Tab>()
        /// Whether a programmatic synchronization is currently updating the controller.
        private var isSynchronizing = false

        /// Creates a coordinator for the supplied selection binding.
        ///
        /// - Parameter selection: The caller-owned selected-tab binding.
        init(selection: Binding<Tab>) {
            self.selection = selection
        }

        /// Reconciles tabs, hosted content, item metadata, minimization, and selection.
        ///
        /// Existing hosting controllers are reused for unchanged tab identities. Removed tabs are
        /// discarded, and a programmatic selection update does not count as a user interaction.
        ///
        /// - Parameters:
        ///   - controller: The native tab bar controller to synchronize.
        ///   - tabs: The current ordered tab identifiers.
        ///   - selection: The current resolved caller selection.
        ///   - configs: Native item configurations keyed by tab identifier.
        ///   - minimizeBehavior: The requested native minimization policy.
        ///   - doubleTapAction: The optional same-tab double-selection callback.
        ///   - content: A builder for each hosted SwiftUI root view.
        func synchronize(
            controller: UITabBarController,
            tabs: [Tab],
            selection: Tab,
            configs: [Tab: ILiquidTabBarItemConfig],
            minimizeBehavior: ILiquidTabBarMinimizeBehavior,
            doubleTapAction: ((Tab) -> Void)?,
            content: (Tab) -> Content
        ) {
            isSynchronizing = true
            defer { isSynchronizing = false }

            self.tabs = tabs
            self.doubleTapAction = doubleTapAction
            let activeTabs = Set(tabs)
            hostingControllers = hostingControllers.filter { activeTabs.contains($0.key) }

            let controllers = tabs.map { tab in
                let hostingController: UIHostingController<Content>
                if let existingController = hostingControllers[tab] {
                    existingController.rootView = content(tab)
                    hostingController = existingController
                } else {
                    hostingController = UIHostingController(rootView: content(tab))
                    hostingControllers[tab] = hostingController
                }

                apply(configs[tab], to: hostingController)
                return hostingController
            }

            if !hasSameControllers(controller.viewControllers, as: controllers) {
                controller.setViewControllers(controllers, animated: false)
            }

            controller.tabBarMinimizeBehavior = minimizeBehavior.uiKitValue

            let snapshot = _ILiquidTabSnapshot(tabs: tabs, configs: configs)
            if let selectedIndex = snapshot.selectedIndex(for: selection),
               controller.selectedIndex != selectedIndex {
                controller.selectedIndex = selectedIndex
            }
        }

        /// Forwards a user-driven native selection to SwiftUI and recognizes same-tab double taps.
        ///
        /// - Parameters:
        ///   - tabBarController: The controller whose selected index changed.
        ///   - viewController: The selected child controller supplied by UIKit.
        func tabBarController(
            _ tabBarController: UITabBarController,
            didSelect viewController: UIViewController
        ) {
            guard !isSynchronizing,
                  tabs.indices.contains(tabBarController.selectedIndex) else {
                return
            }

            let selectedTab = tabs[tabBarController.selectedIndex]
            if selection.wrappedValue != selectedTab {
                selection.wrappedValue = selectedTab
            }

            if interactionState.registerSelection(
                selectedTab,
                at: Date(),
                enabled: doubleTapAction != nil
            ) {
                doubleTapAction?(selectedTab)
            }
        }

        /// Applies an item configuration to a hosted controller's native tab bar item.
        ///
        /// Missing configurations fall back to a question-mark icon and empty title.
        ///
        /// - Parameters:
        ///   - config: The optional item configuration for the tab.
        ///   - controller: The hosting controller whose native item is updated.
        private func apply(
            _ config: ILiquidTabBarItemConfig?,
            to controller: UIHostingController<Content>
        ) {
            let resolvedConfig = config ?? ILiquidTabBarItemConfig(
                icon: "questionmark",
                title: ""
            )
            let item = controller.tabBarItem ?? UITabBarItem()
            item.title = resolvedConfig.title
            item.image = UIImage(systemName: resolvedConfig.icon)
            item.selectedImage = resolvedConfig.selectedIcon.flatMap(UIImage.init(systemName:))
            item.badgeValue = resolvedConfig.badge
            controller.tabBarItem = item
        }

        /// Compares controller arrays by reference identity and order.
        ///
        /// - Parameters:
        ///   - currentControllers: The controller's currently installed children.
        ///   - newControllers: The desired child-controller sequence.
        /// - Returns: `true` when both arrays contain the same instances in the same order.
        private func hasSameControllers(
            _ currentControllers: [UIViewController]?,
            as newControllers: [UIViewController]
        ) -> Bool {
            guard let currentControllers,
                  currentControllers.count == newControllers.count else {
                return false
            }

            return zip(currentControllers, newControllers).allSatisfy { current, new in
                current === new
            }
        }
    }
}
#endif
