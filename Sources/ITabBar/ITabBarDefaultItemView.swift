//
//  ITabBarDefaultItemView.swift
//  ITabBar
//
//  Created by ibabyblue on 2026/05/14.
//  Copyright © 2026 ibabyblue. All rights reserved.
//

import SwiftUI

@MainActor
/// The package-provided icon, title, and badge presentation for a standard tab item.
public struct ITabBarDefaultItemView: View {
    /// The content and animation configuration represented by this view.
    public let config: ITabBarItemConfig
    /// A Boolean value that selects the active or inactive visual treatment.
    public let isSelected: Bool
    /// The colors, fonts, and badge appearance used by the view.
    public let style: ITabBarStyle

    /// Creates the default presentation for a tab item.
    ///
    /// - Parameters:
    ///   - config: The item content configuration.
    ///   - isSelected: Whether the item is currently selected.
    ///   - style: The tab bar style used to render the item.
    public init(config: ITabBarItemConfig, isSelected: Bool, style: ITabBarStyle) {
        self.config = config
        self.isSelected = isSelected
        self.style = style
    }

    /// The icon, optional badge, and title hierarchy for the item.
    public var body: some View {
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
                        .offset(x: 10, y: -2)
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
