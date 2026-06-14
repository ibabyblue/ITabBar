//
//  _FABButton.swift
//  ITabBar
//
//  Created by ibabyblue on 2026/05/14.
//  Copyright © 2026 ibabyblue. All rights reserved.
//

import SwiftUI

@MainActor
struct _FABButton: View {
    let size: CGFloat
    let color: Color
    let onTap: (() -> Void)?

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
