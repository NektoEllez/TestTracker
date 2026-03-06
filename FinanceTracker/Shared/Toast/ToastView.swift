import SwiftUI

struct ToastView: View {
    let message: ToastMessage
    let onDismiss: () -> Void
    
    var body: some View {
        Button {
            Haptics.selection()
            onDismiss()
        } label: {
            HStack(spacing: 12) {
                if let icon = message.icon {
                    Image(systemName: icon)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(iconColor)
                }
                
                Text(message.text)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(backgroundColor)
            .appGlassSurface(cornerRadius: 12)
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(iconColor.opacity(0.35), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(message.text)
        .accessibilityHint("Double tap to dismiss")
    }
    
    private var iconColor: Color {
        switch message.style {
            case .default:
                return .secondary
            case .success:
                return .green
            case .warning:
                return .orange
            case .error:
                return .red
        }
    }
    
    private var backgroundColor: Color {
        switch message.style {
            case .default:
                return Color.cardBackground.opacity(0.45)
            case .success:
                return Color.green.opacity(0.14)
            case .warning:
                return Color.orange.opacity(0.14)
            case .error:
                return Color.red.opacity(0.14)
        }
    }
}

#Preview("ToastView") {
    ToastView(
        message: ToastMessage(
            text: "Saved successfully",
            icon: "checkmark.circle.fill",
            style: .success
        ),
        onDismiss: {}
    )
    .padding()
}
