import SwiftUI

struct ConcaveShape: Shape {
    var fabSize: CGFloat
    var curveRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width, h = rect.height
        let cx = w / 2
        let nr = fabSize / 2 + 4   // notch arc radius
        let cr = min(curveRadius, nr)

        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: cx - nr - cr, y: 0))
        // left shoulder arc: sweeps from top-horizontal into the notch left wall
        path.addArc(
            center: CGPoint(x: cx - nr - cr, y: cr),
            radius: cr,
            startAngle: .degrees(-90), endAngle: .degrees(0), clockwise: false
        )
        // notch bottom arc: clockwise = visually downward in SwiftUI
        path.addArc(
            center: CGPoint(x: cx, y: 0),
            radius: nr,
            startAngle: .degrees(180), endAngle: .degrees(0), clockwise: true
        )
        // right shoulder arc: sweeps from notch right wall back to top
        path.addArc(
            center: CGPoint(x: cx + nr + cr, y: cr),
            radius: cr,
            startAngle: .degrees(180), endAngle: .degrees(-90), clockwise: false
        )
        path.addLine(to: CGPoint(x: w, y: 0))
        path.addLine(to: CGPoint(x: w, y: h))
        path.addLine(to: CGPoint(x: 0, y: h))
        path.closeSubpath()
        return path
    }
}

struct ConvexShape: Shape {
    var fabSize: CGFloat
    var curveRadius: CGFloat
    var domeRise: CGFloat   // how many points the dome rises above y=0

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width, h = rect.height
        let cx = w / 2
        let nr = fabSize / 2 + 4
        let cr = min(curveRadius, nr)
        let rise = domeRise

        path.move(to: CGPoint(x: 0, y: rise))
        path.addLine(to: CGPoint(x: cx - nr - cr, y: rise))
        // left shoulder: arc sweeping up from flat into dome
        path.addArc(
            center: CGPoint(x: cx - nr - cr, y: rise - cr),
            radius: cr,
            startAngle: .degrees(90), endAngle: .degrees(0), clockwise: false
        )
        // dome arc: counter-clockwise = visually upward
        path.addArc(
            center: CGPoint(x: cx, y: rise - cr),
            radius: nr,
            startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false
        )
        // right shoulder: arc sweeping down from dome back to flat
        path.addArc(
            center: CGPoint(x: cx + nr + cr, y: rise - cr),
            radius: cr,
            startAngle: .degrees(180), endAngle: .degrees(90), clockwise: false
        )
        path.addLine(to: CGPoint(x: w, y: rise))
        path.addLine(to: CGPoint(x: w, y: h))
        path.addLine(to: CGPoint(x: 0, y: h))
        path.closeSubpath()
        return path
    }
}

struct _TabBarBackground: View {
    let shape: ITabBarShape
    let style: ITabBarStyle

    var domeRise: CGFloat { style.fabSize / 2 + 4 + style.curveRadius }

    var body: some View {
        switch shape {
        case .plain:
            backgroundContent(Rectangle())
        case .concave:
            backgroundContent(ConcaveShape(fabSize: style.fabSize, curveRadius: style.curveRadius))
        case .convex:
            backgroundContent(ConvexShape(fabSize: style.fabSize, curveRadius: style.curveRadius, domeRise: domeRise))
        }
    }

    @ViewBuilder
    private func backgroundContent<S: Shape>(_ shape: S) -> some View {
        if style.useLiquidGlass, #available(iOS 26, *) {
            shape.fill(style.backgroundMaterial)
        } else if let color = style.backgroundColor {
            shape.fill(color)
        } else {
            shape.fill(style.backgroundMaterial)
        }
    }
}
