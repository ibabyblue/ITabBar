//
//  DemoComponents.swift
//  ITabBarDemo
//
//  Created by ibabyblue on 2026/07/17.
//  Copyright © 2026 ibabyblue. All rights reserved.
//

import SwiftUI

struct DemoCatalogLabel: View {
    let example: DemoExample

    var body: some View {
        Label {
            VStack(alignment: .leading, spacing: 3) {
                Text(example.title)
                Text(example.summary)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        } icon: {
            Image(systemName: example.systemImage)
        }
    }
}

struct DemoStatusRow: View {
    let title: String
    let value: String
    let accessibilityIdentifier: String

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .font(.callout.monospaced())
                .foregroundStyle(.secondary)
                .accessibilityIdentifier(accessibilityIdentifier)
        }
    }
}

struct DemoControlCard<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 12) {
            content
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}
