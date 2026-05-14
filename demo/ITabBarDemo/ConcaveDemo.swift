import SwiftUI
import ITabBar

private enum ConcaveTab: String, CaseIterable, Hashable {
    case home, explore, messages, profile
}

struct ConcaveDemo: View {
    @State private var selection: ConcaveTab = .home
    @State private var centerTapCount = 0
    @Environment(\.dismiss) private var dismiss

    private let configs: [ConcaveTab: ITabBarItemConfig] = [
        .home:     ITabBarItemConfig(icon: "house",           title: "Home"),
        .explore:  ITabBarItemConfig(icon: "magnifyingglass", title: "Explore"),
        .messages: ITabBarItemConfig(icon: "message",         title: "Messages"),
        .profile:  ITabBarItemConfig(icon: "person",          title: "Profile"),
    ]

    var body: some View {
        ITabBar(
            tabs: ConcaveTab.allCases,
            selection: $selection,
            shape: .concave,
            configs: configs,
            onCenterTap: { centerTapCount += 1 }
        ) { tab in
            VStack {
                Text(tab.rawValue.capitalized).font(.largeTitle.bold())
                Text("+ tapped \(centerTapCount) times").foregroundStyle(.secondary)
            }
        }
        .overlay(alignment: .topLeading) {
            Button("Close") { dismiss() }.padding()
        }
    }
}
