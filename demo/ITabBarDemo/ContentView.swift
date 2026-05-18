import SwiftUI

enum Demo: String, CaseIterable, Identifiable {
    case plain     = "Plain"
    case concave   = "Concave (Water Drop)"
    case convex    = "Convex (Dome)"
    case animation = "Animations"
    case lottie    = "Lottie Animation"

    var id: String { rawValue }
}

struct ContentView: View {
    @State private var activeDemo: Demo?

    var body: some View {
        NavigationStack {
            List(Demo.allCases) { demo in
                Button(demo.rawValue) { activeDemo = demo }
            }
            .navigationTitle("ITabBar Demo")
        }
        .fullScreenCover(item: $activeDemo) { demo in
            switch demo {
            case .plain:     PlainDemo()
            case .concave:   ConcaveDemo()
            case .convex:    ConvexDemo()
            case .animation: AnimationDemo()
            case .lottie:    LottieAnimationDemo()
            }
        }
    }
}
