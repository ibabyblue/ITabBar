import SwiftUI

public struct ITabBarItemConfig: Sendable {
    public var icon: String
    public var selectedIcon: String?
    public var title: String
    public var animation: ITabBarAnimation
    public var badge: String?

    public init(
        icon: String,
        selectedIcon: String? = nil,
        title: String,
        animation: ITabBarAnimation = .bounce,
        badge: String? = nil
    ) {
        self.icon = icon
        self.selectedIcon = selectedIcon
        self.title = title
        self.animation = animation
        self.badge = badge
    }
}

public enum ITabBarAnimation: Sendable {
    case bounce
    case wiggle
    case pop
    case none
    case custom(@MainActor @Sendable (Bool) -> AnyView)
}
