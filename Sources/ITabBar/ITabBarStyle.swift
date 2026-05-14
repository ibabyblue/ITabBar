import SwiftUI

public struct ITabBarStyle: Sendable {
    public var selectedColor: Color       = .primary
    public var unselectedColor: Color     = .secondary
    public var selectedFont: Font         = .system(size: 10, weight: .medium)
    public var unselectedFont: Font       = .system(size: 10, weight: .regular)

    public var backgroundColor: Color?   = nil
    public var backgroundMaterial: Material = .ultraThinMaterial
    public var useLiquidGlass: Bool      = false

    public var height: CGFloat           = 56
    public var fabSize: CGFloat          = 52
    public var fabColor: Color           = .blue
    public var itemSpacing: CGFloat      = 0

    public var badgeColor: Color         = .red
    public var badgeFont: Font           = .system(size: 10, weight: .bold)

    public var curveRadius: CGFloat      = 28

    public init() {}
}
