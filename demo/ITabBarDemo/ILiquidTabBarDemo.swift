//
//  ILiquidTabBarDemo.swift
//  ITabBarDemo
//
//  Created by ibabyblue on 2026/07/16.
//  Copyright © 2026 ibabyblue. All rights reserved.
//

#if compiler(>=6.2)
import SwiftUI
import ITabBar

@available(iOS 26.0, *)
private enum LiquidTab: String, CaseIterable, Hashable {
    case home
    case discover
    case activity
    case profile

    var title: String { rawValue.capitalized }
}

@available(iOS 26.0, *)
struct ILiquidTabBarDemo: View {
    @State private var selection: LiquidTab = .home
    @State private var tabs = LiquidTab.allCases
    @State private var minimizeBehavior: ILiquidTabBarMinimizeBehavior = .onScrollDown
    @Environment(\.dismiss) private var dismiss

    private let configs: [LiquidTab: ILiquidTabBarItemConfig] = [
        .home: .init(icon: "house", selectedIcon: "house.fill", title: "Home"),
        .discover: .init(icon: "safari", selectedIcon: "safari.fill", title: "Discover"),
        .activity: .init(
            icon: "bell",
            selectedIcon: "bell.fill",
            title: "Activity",
            badge: "3"
        ),
        .profile: .init(icon: "person", selectedIcon: "person.fill", title: "Profile")
    ]

    var body: some View {
        ILiquidTabBar(
            tabs: tabs,
            selection: $selection,
            configs: configs,
            minimizeBehavior: minimizeBehavior
        ) { tab in
            page(for: tab)
        }
    }

    private func page(for tab: LiquidTab) -> some View {
        ZStack {
            LinearGradient(
                colors: colors(for: tab),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 18) {
                    HStack {
                        Button("Close") { dismiss() }
                        Spacer()
                        Text("iOS 26 Native")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }

                    VStack(spacing: 8) {
                        Image(systemName: configs[tab]?.selectedIcon ?? configs[tab]?.icon ?? "questionmark")
                            .font(.system(size: 42, weight: .semibold))
                        Text(tab.title)
                            .font(.largeTitle.bold())
                        Text("Tap another tab to watch the native Liquid Glass lens stretch and move.")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.vertical, 28)

                    controls

                    ForEach(0..<14, id: \.self) { index in
                        HStack(spacing: 14) {
                            Image(systemName: "sparkles")
                                .foregroundStyle(.blue)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Scrollable item \(index + 1)")
                                    .font(.headline)
                                Text("Scroll to exercise the selected minimize behavior.")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                        .padding()
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18))
                    }
                }
                .padding()
            }
        }
    }

    private var controls: some View {
        VStack(spacing: 14) {
            Picker("Minimize", selection: $minimizeBehavior) {
                ForEach(ILiquidTabBarMinimizeBehavior.allCases, id: \.self) { behavior in
                    Text(title(for: behavior)).tag(behavior)
                }
            }
            .pickerStyle(.menu)

            Button("Select next tab") {
                guard let currentIndex = tabs.firstIndex(of: selection), !tabs.isEmpty else {
                    return
                }
                selection = tabs[(currentIndex + 1) % tabs.count]
            }

            Button(tabs.contains(.profile) ? "Remove Profile tab" : "Restore Profile tab") {
                if tabs.contains(.profile) {
                    tabs.removeAll { $0 == .profile }
                } else {
                    tabs = LiquidTab.allCases
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
    }

    private func colors(for tab: LiquidTab) -> [Color] {
        switch tab {
        case .home: [.cyan.opacity(0.42), .indigo.opacity(0.28)]
        case .discover: [.orange.opacity(0.46), .pink.opacity(0.3)]
        case .activity: [.purple.opacity(0.4), .blue.opacity(0.28)]
        case .profile: [.green.opacity(0.4), .mint.opacity(0.28)]
        }
    }

    private func title(for behavior: ILiquidTabBarMinimizeBehavior) -> String {
        switch behavior {
        case .automatic: "Automatic"
        case .never: "Never"
        case .onScrollDown: "On Scroll Down"
        case .onScrollUp: "On Scroll Up"
        }
    }
}
#endif
