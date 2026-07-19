//
//  DemoComponents.swift
//  ITabBarDemo
//
//  Created by ibabyblue on 2026/07/17.
//  Copyright © 2026 ibabyblue. All rights reserved.
//

import SwiftUI

/// A catalog row that presents an example's icon, title, and summary.
struct DemoCatalogLabel: View {
    /// The example described by this row.
    let example: DemoExample

    /// The labeled two-line catalog presentation.
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

/// A labeled value row with a stable UI-test accessibility identifier.
struct DemoStatusRow: View {
    /// The status label shown on the leading edge.
    let title: String
    /// The observable value shown on the trailing edge.
    let value: String
    /// The identifier used to locate the value in UI tests.
    let accessibilityIdentifier: String

    /// The aligned label and monospaced status value.
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

/// A reusable material card for interactive controls and observable status values.
struct DemoControlCard<Content: View>: View {
    /// The card content built during initialization.
    private let content: Content

    /// Creates a control card from a SwiftUI content builder.
    ///
    /// - Parameter content: The controls or status rows placed inside the card.
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    /// The padded material-backed card hierarchy.
    var body: some View {
        VStack(spacing: 12) {
            content
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}
