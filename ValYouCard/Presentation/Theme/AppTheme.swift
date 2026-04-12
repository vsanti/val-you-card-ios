import SwiftUI

enum AppTheme {
    // Brand colors matching Tailwind config
    static let orange = Color(hex: "F34A32")
    static let darkOrange = Color(hex: "D73721")
    static let blue = Color(hex: "27A8E1")
    static let red = Color(hex: "ED523C")
    static let black = Color(hex: "251D1D")
    static let darkGrey = Color(hex: "676767")
    static let grey = Color(hex: "988F8E")

    // Gradient matching the hero section
    static let heroGradient = LinearGradient(
        colors: [Color(hex: "F34A32"), Color(hex: "FFAF57")],
        startPoint: .leading,
        endPoint: .trailing
    )

    // Card styling
    static let cardBackground = Color(hex: "FAFAFA")
    static let cardCornerRadius: CGFloat = 12
    static let sectionCornerRadius: CGFloat = 16
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
