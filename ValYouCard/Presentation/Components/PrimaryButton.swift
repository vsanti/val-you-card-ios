import SwiftUI

struct PrimaryButton: View {
    let title: String
    var isLoading: Bool = false
    var isDisabled: Bool = false
    var style: ButtonVariant = .orange
    let action: () -> Void

    enum ButtonVariant {
        case orange, blue, outline

        var backgroundColor: Color {
            switch self {
            case .orange: return AppTheme.orange
            case .blue: return AppTheme.blue
            case .outline: return .clear
            }
        }

        var foregroundColor: Color {
            switch self {
            case .orange, .blue: return .white
            case .outline: return AppTheme.blue
            }
        }
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .tint(style.foregroundColor)
                }
                Text(title)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(style.backgroundColor)
            .foregroundStyle(style.foregroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay {
                if style == .outline {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(AppTheme.blue, lineWidth: 1)
                }
            }
        }
        .disabled(isLoading || isDisabled)
        .opacity(isDisabled ? 0.5 : 1)
    }
}
