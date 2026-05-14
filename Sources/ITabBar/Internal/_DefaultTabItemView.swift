import SwiftUI

@MainActor
struct _DefaultTabItemView: View {
    let config: ITabBarItemConfig
    let isSelected: Bool
    let style: ITabBarStyle

    var body: some View {
        VStack(spacing: 3) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: isSelected ? (config.selectedIcon ?? config.icon) : config.icon)
                    .font(.system(size: 22))
                    .foregroundStyle(isSelected ? style.selectedColor : style.unselectedColor)

                if let badge = badgeTruncated(config.badge), !badge.isEmpty {
                    Text(badge)
                        .font(style.badgeFont)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(style.badgeColor, in: Capsule())
                        .offset(x: 10, y: -6)
                }
            }

            Text(config.title)
                .font(isSelected ? style.selectedFont : style.unselectedFont)
                .foregroundStyle(isSelected ? style.selectedColor : style.unselectedColor)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
    }
}
