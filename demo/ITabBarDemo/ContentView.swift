//
//  ContentView.swift
//  ITabBarDemo
//
//  Created by ibabyblue on 2026/05/14.
//  Copyright © 2026 ibabyblue. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                ForEach(DemoSection.allCases) { section in
                    let examples = DemoExample.availableExamples.filter { $0.section == section }
                    if !examples.isEmpty {
                        Section(section.title) {
                            ForEach(examples) { example in
                                NavigationLink(value: example) {
                                    DemoCatalogLabel(example: example)
                                }
                                .accessibilityIdentifier(example.accessibilityIdentifier)
                            }
                        }
                    }
                }
            }
            .navigationTitle("ITabBar")
            .navigationDestination(for: DemoExample.self) { example in
                switch example {
                case .basicPlain:
                    BasicPlainDemo()
                case .tapInteractions:
                    TapInteractionsDemo()
                case .concaveFAB:
                    ConcaveDemo()
                case .convexFAB:
                    ConvexDemo()
                case .customStyling:
                    CustomStylingDemo()
                case .customTabItem:
                    CustomTabItemDemo()
                case .builtInAnimations:
                    AnimationDemo()
                case .lottieAnimation:
                    LottieAnimationDemo()
                case .dynamicTabs:
                    DynamicTabsDemo()
                case .nativeLiquidGlass:
                    if #available(iOS 26.0, *) {
#if compiler(>=6.2)
                        ILiquidTabBarDemo()
#else
                        ContentUnavailableView("Requires Swift 6.2", systemImage: "hammer")
#endif
                    } else {
                        ContentUnavailableView("Requires iOS 26", systemImage: "iphone")
                    }
                }
            }
        }
    }
}
