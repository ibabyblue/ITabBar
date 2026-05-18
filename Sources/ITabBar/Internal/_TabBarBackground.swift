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

// Dome shape: three segments per side.
//   1. flat bar top
//   2. cubic shoulder rising smoothly from flat top to wrap-arc entry
//   3. wrap arc — concentric with the FAB (radius = fabRadius + fabGap), arcs over
//      the FAB top so the bar's edge appears to hug the button at a fixed gap
// The cubic shoulder's end tangent is matched analytically to the wrap arc's tangent
// at the entry point, so the shoulder→wrap junction is curvature-continuous.
struct ConvexShape: Shape {
    var cornerRadius: CGFloat
    var fabRadius: CGFloat           // = fabSize / 2
    var fabGap: CGFloat              // gap between FAB and bar's wrap arc
    var fabCenterY: CGFloat          // FAB center y (positive = inside bar, below bar top)
    var shoulderExtension: CGFloat   // how far the shoulder cubic extends beyond the wrap-entry

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let cr2 = cornerRadius / 2
        let w = rect.width, h = rect.height
        let cx = w / 2

        // Wrap circle: concentric with FAB, radius = fabRadius + fabGap.
        // The bar's edge follows this arc over the FAB so there's always exactly
        // fabGap between FAB and bar edge in the wrap region.
        let wrapR = fabRadius + fabGap
        // Wrap arc starts where the bar leaves the flat top — at y = -wrapEntryY above bar top.
        // Use fabGap as the entry height: small lift so the shoulder cubic has somewhere to land.
        let wrapEntryY = fabGap
        // Wrap entry x offset (from cx) on the wrap circle at y = -wrapEntryY
        let entryDy = fabCenterY + wrapEntryY   // vertical distance from wrap center to entry y
        let entryDxSquared = wrapR * wrapR - entryDy * entryDy
        let wrapEntryX = entryDxSquared > 0 ? sqrt(entryDxSquared) : 0

        // Shoulder cubic starts at (cx ± (wrapEntryX + shoulderExtension), y = 0)
        let shoulderStartX = wrapEntryX + shoulderExtension

        // Tangent at the wrap-entry point along the traversal direction (going up over FAB).
        // For SwiftUI's y-down arc with clockwise:false (angles increasing),
        // dP/dθ at angle θ is (-sin θ, cos θ) · R.
        // Direction normalized: (-sin θ, cos θ).
        let entryAngle = atan2(-wrapEntryY - fabCenterY, -wrapEntryX)
        let tangentDx = -sin(entryAngle)
        let tangentDy = cos(entryAngle)

        // Cubic control-point distance: roughly 1/3 of the cubic's chord length.
        let chord = sqrt(shoulderExtension * shoulderExtension + wrapEntryY * wrapEntryY)
        let k = chord / 3

        let shoulderStartL = CGPoint(x: cx - shoulderStartX, y: 0)
        let wrapEntryL = CGPoint(x: cx - wrapEntryX, y: -wrapEntryY)
        // Left cubic: tangent horizontal at start, tangent (tangentDx, tangentDy) at end.
        let c1L = CGPoint(x: shoulderStartL.x + k, y: 0)
        let c2L = CGPoint(x: wrapEntryL.x - k * tangentDx, y: wrapEntryL.y - k * tangentDy)

        // Right cubic: mirror across x = cx
        let wrapEntryR = CGPoint(x: cx + wrapEntryX, y: -wrapEntryY)
        let shoulderStartR = CGPoint(x: cx + shoulderStartX, y: 0)
        let c1R = CGPoint(x: wrapEntryR.x + k * tangentDx, y: wrapEntryR.y - k * tangentDy)
        let c2R = CGPoint(x: shoulderStartR.x - k, y: 0)

        // Wrap arc angles (SwiftUI degrees, normalized to [0, 360))
        let leftAngleRad = atan2(wrapEntryL.y - fabCenterY, wrapEntryL.x - cx)
        let rightAngleRad = atan2(wrapEntryR.y - fabCenterY, wrapEntryR.x - cx)
        var leftAngleDeg = Double(leftAngleRad * 180 / .pi)
        if leftAngleDeg < 0 { leftAngleDeg += 360 }
        var rightAngleDeg = Double(rightAngleRad * 180 / .pi)
        if rightAngleDeg < 0 { rightAngleDeg += 360 }

        path.move(to: CGPoint(x: 0, y: 0))

        // top-left corner
        path.addArc(
            center: CGPoint(x: cr2, y: cr2), radius: cr2,
            startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false
        )

        // flat bar top to left shoulder start
        path.addLine(to: shoulderStartL)

        // left shoulder cubic — smooth rise from flat to wrap entry
        path.addCurve(to: wrapEntryL, control1: c1L, control2: c2L)

        // wrap arc over the FAB — concentric with FAB, gap = fabGap
        path.addArc(
            center: CGPoint(x: cx, y: fabCenterY), radius: wrapR,
            startAngle: .degrees(leftAngleDeg), endAngle: .degrees(rightAngleDeg), clockwise: false
        )

        // right shoulder cubic — mirror of left
        path.addCurve(to: shoulderStartR, control1: c1R, control2: c2R)

        // flat bar top to top-right corner
        path.addLine(to: CGPoint(x: w - cr2, y: 0))

        // top-right corner
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
                fabRadius: style.fabSize / 2,
                fabGap: style.fabGap,
                fabCenterY: -style.convexProtrusion + style.fabSize / 2,
                shoulderExtension: style.fabGap * 3
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
