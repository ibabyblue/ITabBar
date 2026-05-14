import SwiftUI

public struct ITabBar<Tab: Hashable, Content: View, TabItemView: View & Sendable>: View {
    private let tabs: [Tab]
    @Binding private var selection: Tab
    private let shape: ITabBarShape
    private let style: ITabBarStyle
    private let onCenterTap: (() -> Void)?
    private let content: (Tab) -> Content
    private let tabItem: (Tab, Bool) -> TabItemView
    private var doubleTapAction: ((Tab) -> Void)?
    private var longPressAction: ((Tab) -> Void)?
    private var animationProvider: (@Sendable (Tab) -> ITabBarAnimation)?

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

    private var validSelection: Tab {
        validatedSelection(selection, in: tabs) ?? selection
    }

    private var fabYOffset: CGFloat {
        switch shape {
        case .plain:   return 0
        case .concave: return -(style.fabSize / 2 + 8)
        case .convex:  return -(style.fabSize / 2 + style.curveRadius / 2 + 4)
        }
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            if let idx = tabs.firstIndex(of: validSelection) {
                content(tabs[idx])
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
            }

            VStack(spacing: 0) {
                Spacer()
                ZStack(alignment: .top) {
                    _TabBarBackground(shape: shape, style: style)

                    HStack(spacing: style.itemSpacing > 0 ? style.itemSpacing : nil) {
                        ForEach(Array(tabs.enumerated()), id: \.offset) { idx, tab in
                            if shape != .plain && idx == tabs.count / 2 {
                                Spacer().frame(width: style.fabSize + 16)
                            }
                            let doubleTap = doubleTapAction
                            let longPress = longPressAction
                            _TabBarItem(
                                isSelected: validSelection == tab,
                                animation: animationProvider?(tab) ?? .bounce,
                                onTap: { selection = tab },
                                onDoubleTap: doubleTap.map { action in { action(tab) } },
                                onLongPress: longPress.map { action in { action(tab) } }
                            ) {
                                tabItem(tab, validSelection == tab)
                            }
                        }
                    }
                    .padding(.horizontal, 8)
                    .frame(height: style.height)

                    if shape != .plain {
                        _FABButton(size: style.fabSize, color: style.fabColor, onTap: onCenterTap)
                            .offset(y: fabYOffset)
                    }
                }
                .frame(height: style.height)
                .clipped(antialiased: false)
            }
        }
        .onChange(of: selection) { _, newValue in
            if !tabs.contains(newValue), let first = tabs.first {
                selection = first
            }
        }
    }

    public func onTabDoubleTap(perform action: @escaping (Tab) -> Void) -> Self {
        var copy = self
        copy.doubleTapAction = action
        return copy
    }

    public func onTabLongPress(perform action: @escaping (Tab) -> Void) -> Self {
        var copy = self
        copy.longPressAction = action
        return copy
    }
}

// MARK: - Convenience init (default template)

public extension ITabBar where TabItemView == ITabBarDefaultItemView {
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
        self.animationProvider = { tab in configs[tab]?.animation ?? .bounce }
    }
}
