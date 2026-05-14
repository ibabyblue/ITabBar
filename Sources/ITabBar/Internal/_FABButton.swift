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
                .background(color, in: Circle())
                .shadow(color: color.opacity(0.4), radius: 8, y: 4)
        }
        .buttonStyle(.plain)
    }
}
