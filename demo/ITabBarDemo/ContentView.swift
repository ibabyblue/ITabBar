//
//  ContentView.swift
//  ITabBarDemo
//
//  Created by ibabyblue on 2026/05/14.
//  Copyright © 2026 ibabyblue. All rights reserved.
//

import SwiftUI

enum Demo: String, CaseIterable, Identifiable {
    case plain     = "Plain"
    case concave   = "Concave (Water Drop)"
    case convex    = "Convex (Dome)"
    case animation = "Animations"
    case lottie    = "Lottie Animation"
#if compiler(>=6.2)
    case liquid    = "Liquid Tab Bar (iOS 26+)"
#endif

    var id: String { rawValue }
}

struct ContentView: View {
    @State private var activeDemo: Demo?

    private var availableDemos: [Demo] {
        Demo.allCases.filter { demo in
#if compiler(>=6.2)
            if demo == .liquid {
                if #available(iOS 26.0, *) {
                    return true
                }
                return false
            }
#endif
            return true
        }
    }

    var body: some View {
        NavigationStack {
            List(availableDemos) { demo in
                Button(demo.rawValue) { activeDemo = demo }
            }
            .navigationTitle("ITabBar Demo")
        }
        .fullScreenCover(item: $activeDemo) { demo in
            switch demo {
            case .plain: PlainDemo()
            case .concave: ConcaveDemo()
            case .convex: ConvexDemo()
            case .animation: AnimationDemo()
            case .lottie: LottieAnimationDemo()
#if compiler(>=6.2)
            case .liquid:
                if #available(iOS 26.0, *) {
                    ILiquidTabBarDemo()
                }
#endif
            }
        }
    }
}
