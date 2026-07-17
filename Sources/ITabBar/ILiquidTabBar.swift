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
    private let tabs: [Tab]
    @Binding private var selection: Tab
    private let configs: [Tab: ILiquidTabBarItemConfig]
    private let minimizeBehavior: ILiquidTabBarMinimizeBehavior
    private let content: (Tab) -> Content
    private var doubleTapAction: ((Tab) -> Void)?

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

    private func correctSelectionIfNeeded() {
        if let correctedSelection = selectionCorrection(selection, in: tabs) {
            selection = correctedSelection
        }
    }

    public func onTabDoubleTap(perform action: @escaping (Tab) -> Void) -> Self {
        var copy = self
        copy.doubleTapAction = action
        return copy
    }
}

@available(iOS 26.0, *)
private struct _ILiquidTabControllerBridge<Tab: Hashable, Content: View>: UIViewControllerRepresentable {
    let tabs: [Tab]
    @Binding var selection: Tab
    let configs: [Tab: ILiquidTabBarItemConfig]
    let minimizeBehavior: ILiquidTabBarMinimizeBehavior
    let doubleTapAction: ((Tab) -> Void)?
    let content: (Tab) -> Content

    func makeCoordinator() -> Coordinator {
        Coordinator(selection: $selection)
    }

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
    final class Coordinator: NSObject, UITabBarControllerDelegate {
        var selection: Binding<Tab>

        private var tabs: [Tab] = []
        private var hostingControllers: [Tab: UIHostingController<Content>] = [:]
        private var doubleTapAction: ((Tab) -> Void)?
        private var interactionState = _ILiquidTabInteractionState<Tab>()
        private var isSynchronizing = false

        init(selection: Binding<Tab>) {
            self.selection = selection
        }

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
