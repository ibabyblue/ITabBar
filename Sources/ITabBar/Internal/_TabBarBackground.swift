import SwiftUI

struct ConcaveShape: Shape {
    var curveRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let radius = curveRadius
        let v = radius * 2
        let w = rect.width, h = rect.height

        path.move(to: CGPoint(x: 0, y: 0))

        // top-left rounded corner
        path.addArc(
            center: CGPoint(x: radius / 2, y: radius / 2),
            radius: radius / 2,
            startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false
        )
        // left shoulder arc connecting corner to notch
        path.addArc(
            center: CGPoint(x: (w / 2 - radius) - radius + v * 0.04 + radius / 2, y: radius / 2),
            radius: radius / 2,
            startAngle: .degrees(270), endAngle: .degrees(340), clockwise: false
        )
        // center notch arc (dips downward)
        path.addArc(
            center: CGPoint(x: w / 2, y: 0),
            radius: v / 2,
            startAngle: .degrees(160), endAngle: .degrees(20), clockwise: true
        )
        // right shoulder arc
        path.addArc(
            center: CGPoint(x: (w - (w / 2 - radius)) - v * 0.04 + radius / 2, y: radius / 2),
            radius: radius / 2,
            startAngle: .degrees(200), endAngle: .degrees(270), clockwise: false
        )
        // top-right rounded corner
        path.addArc(
            center: CGPoint(x: w - radius / 2, y: radius / 2),
            radius: radius / 2,
            startAngle: .degrees(270), endAngle: .degrees(360), clockwise: false
        )

        path.addLine(to: CGPoint(x: w, y: h))
        path.addLine(to: CGPoint(x: 0, y: h))

        return path
    }
}

// Single smooth dome arc from flat edge to flat edge.
// Connection half-width  = fabSize/2 + fabGap  → controls how wide the opening is.
// domePeak               = convexProtrusion + fabGap → controls dome height.
// Arc center is derived analytically so the arc passes through both edge connection
// points and the peak — no separate shoulder arcs, fully smooth.
struct ConvexShape: Shape {
    var cornerRadius: CGFloat   // matches ConcaveShape corner radius (style.curveRadius)
    var domeHalfWidth: CGFloat  // = fabSize/2 + fabGap
    var domePeak: CGFloat       // = convexProtrusion + fabGap

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let cr2 = cornerRadius / 2
        let w = rect.width, h = rect.height
        let cx = w / 2

        path.move(to: CGPoint(x: 0, y: 0))

        // top-left corner — identical to ConcaveShape
        path.addArc(
            center: CGPoint(x: cr2, y: cr2), radius: cr2,
            startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false
        )

        // Dome arc: single smooth arc on a circle centered at (cx, yc).
        // Passes through (cx ± domeHalfWidth, 0) on the flat edge and peaks at (cx, -domePeak).
        // yc derived from: domeHalfWidth² + yc² = (yc + domePeak)²
        let yc = (domeHalfWidth * domeHalfWidth - domePeak * domePeak) / (2 * domePeak)
        let domeR = yc + domePeak

        // Angles from (cx, yc) to the connection points
        let startRad: CGFloat = atan2(-yc, -domeHalfWidth)
        let endRad:   CGFloat = atan2(-yc,  domeHalfWidth)
        var startDeg = Double(startRad * 180 / .pi); if startDeg < 0 { startDeg += 360 }
        var endDeg   = Double(endRad   * 180 / .pi); if endDeg   < 0 { endDeg   += 360 }

        // addArc implicitly draws the flat-edge line from the corner arc end to the dome start
        path.addArc(
            center: CGPoint(x: cx, y: yc), radius: domeR,
            startAngle: .degrees(startDeg), endAngle: .degrees(endDeg), clockwise: false
        )

        // top-right corner — identical to ConcaveShape (implicit flat-edge line to here)
        path.addArc(
            center: CGPoint(x: w - cr2, y: cr2), radius: cr2,
            startAngle: .degrees(270), endAngle: .degrees(360), clockwise: false
        )

        path.addLine(to: CGPoint(x: w, y: h))
        path.addLine(to: CGPoint(x: 0, y: h))

        return path
    }
}

struct _TabBarBackground: View {
    let shape: ITabBarShape
    let style: ITabBarStyle

    var body: some View {
        switch shape {
        case .plain:
            backgroundContent(Rectangle())
        case .concave:
            backgroundContent(ConcaveShape(curveRadius: style.curveRadius))
        case .convex:
            backgroundContent(ConvexShape(
                cornerRadius: style.curveRadius,
                domeHalfWidth: style.fabSize / 2 + style.fabGap,
                domePeak: style.convexProtrusion + style.fabGap
            ))
        }
    }

    @ViewBuilder
    private func backgroundContent<S: Shape>(_ shape: S) -> some View {
        if let color = style.backgroundColor {
            shape.fill(color)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: -1)
        } else {
            // TODO: iOS 26 — replace with .glassEffect() modifier when SDK available
            shape.fill(style.backgroundMaterial)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: -1)
        }
    }
}
