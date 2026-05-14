import SwiftUI
import ITabBar

private enum ConvexTab: String, CaseIterable, Hashable {
    case home, explore, messages, profile
}

struct ConvexDemo: View {
    @State private var selection: ConvexTab = .home
    @State private var centerTapCount = 0
    @Environment(\.dismiss) private var dismiss

    private let configs: [ConvexTab: ITabBarItemConfig] = [
        .home:     ITabBarItemConfig(icon: "house",           title: "Home"),
        .explore:  ITabBarItemConfig(icon: "magnifyingglass", title: "Explore"),
        .messages: ITabBarItemConfig(icon: "message",         title: "Messages"),
        .profile:  ITabBarItemConfig(icon: "person",          title: "Profile"),
    ]

    var body: some View {
        ITabBar(
            tabs: ConvexTab.allCases,
            selection: $selection,
            shape: .convex,
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
