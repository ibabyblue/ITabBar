import SwiftUI

private let fabGap: CGFloat = 4   // gap between notch/dome arc and FAB edge

struct ConcaveShape: Shape {
    var fabSize: CGFloat
    var curveRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width, h = rect.height
        let cx = w / 2
        let nr = fabSize / 2 + fabGap   // notch arc radius
        let cr = min(curveRadius, nr)

        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: cx - nr - cr, y: 0))
        // left shoulder: quad curve from top edge into notch
        path.addQuadCurve(
            to: CGPoint(x: cx - nr, y: nr),
            control: CGPoint(x: cx - nr, y: 0)
        )
        // notch bottom arc: clockwise = visually downward in SwiftUI
        path.addArc(
            center: CGPoint(x: cx, y: 0),
            radius: nr,
            startAngle: .degrees(180), endAngle: .degrees(0), clockwise: true
        )
        // right shoulder: quad curve from notch back to top edge
        path.addQuadCurve(
            to: CGPoint(x: cx + nr + cr, y: 0),
            control: CGPoint(x: cx + nr, y: 0)
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
        let nr = fabSize / 2 + fabGap
        let cr = min(curveRadius, nr)
        let rise = domeRise

        path.move(to: CGPoint(x: 0, y: rise))
        path.addLine(to: CGPoint(x: cx - nr - cr, y: rise))
        // left shoulder: quad curve from flat into dome
        path.addQuadCurve(
            to: CGPoint(x: cx - nr, y: rise - nr),
            control: CGPoint(x: cx - nr, y: rise)
        )
        // dome arc: counter-clockwise = visually upward
        path.addArc(
            center: CGPoint(x: cx, y: rise - cr),
            radius: nr,
            startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false
        )
        // right shoulder: quad curve from dome back to flat
        path.addQuadCurve(
            to: CGPoint(x: cx + nr + cr, y: rise),
            control: CGPoint(x: cx + nr, y: rise)
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

    private var domeRise: CGFloat { style.fabSize / 2 + fabGap + style.curveRadius }

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
        if let color = style.backgroundColor {
            shape.fill(color)
        } else {
            // TODO: iOS 26 — replace with .glassEffect() modifier when SDK available
            shape.fill(style.backgroundMaterial)
        }
    }
}
