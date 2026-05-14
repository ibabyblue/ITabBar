import SwiftUI
import ITabBar

private enum AnimTab: String, CaseIterable, Hashable {
    case bounce, wiggle, pop, none_
    var title: String { self == .none_ ? "None" : rawValue.capitalized }
    var animation: ITabBarAnimation {
        switch self {
        case .bounce: return .bounce
        case .wiggle: return .wiggle
        case .pop:    return .pop
        case .none_:  return .none
        }
    }
}

struct AnimationDemo: View {
    @State private var selection: AnimTab = .bounce
    @Environment(\.dismiss) private var dismiss

    private let style: ITabBarStyle = {
        var s = ITabBarStyle()
        s.selectedColor = .orange
        s.fabColor = .orange
        return s
    }()

    var body: some View {
        let currentStyle = style
        ITabBar(
            tabs: AnimTab.allCases,
            selection: $selection,
            shape: .concave,
            style: currentStyle,
            onCenterTap: nil
        ) { tab in
            Text(tab.title).font(.largeTitle.bold())
        } tabItem: { tab, isSelected in
            ITabBarDefaultItemView(
                config: ITabBarItemConfig(
                    icon: "star",
                    selectedIcon: "star.fill",
                    title: tab.title,
                    animation: tab.animation
                ),
                isSelected: isSelected,
                style: currentStyle
            )
        }
        .overlay(alignment: .topLeading) {
            Button("Close") { dismiss() }.padding()
        }
    }
}
