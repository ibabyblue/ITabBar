//
//  _FABButton.swift
//  ITabBar
//
//  Created by ibabyblue on 2026/05/14.
//  Copyright © 2026 ibabyblue. All rights reserved.
//

import SwiftUI

@MainActor
/// The circular center action button rendered by curved tab bar shapes.
struct _FABButton: View {
    /// The button diameter, in points.
    let size: CGFloat
    /// The base color used by the gradient fill and shadow.
    let color: Color
    /// The optional action invoked when the button is tapped.
    let onTap: (() -> Void)?

    /// The gradient plus-icon button presentation.
    var body: some View {
        Button {
            onTap?()
        } label: {
            Image(systemName: "plus")
                .font(.system(size: size * 0.38, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: size, height: size)
                .background(
                    Circle().fill(
                        LinearGradient(
                            colors: [color.opacity(0.85), color],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                )
                .shadow(color: color.opacity(0.3), radius: 10, x: 8, y: 16)
        }
        .buttonStyle(.plain)
    }
}
