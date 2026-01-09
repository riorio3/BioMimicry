import SwiftUI

struct RetroTheme {
    // Colors
    static let background = Color(red: 0.02, green: 0.02, blue: 0.02)
    static let primaryGreen = Color(red: 0.0, green: 1.0, blue: 0.4)
    static let dimGreen = Color(red: 0.0, green: 0.6, blue: 0.25)
    static let darkGreen = Color(red: 0.0, green: 0.3, blue: 0.12)
    static let scanlineColor = Color.green.opacity(0.03)
    static let glowColor = Color(red: 0.0, green: 1.0, blue: 0.4).opacity(0.6)

    // Fonts
    static func terminalFont(_ size: CGFloat) -> Font {
        .system(size: size, weight: .medium, design: .monospaced)
    }

    static func headerFont(_ size: CGFloat) -> Font {
        .system(size: size, weight: .bold, design: .monospaced)
    }
}

// Scanline overlay effect
struct ScanlineOverlay: View {
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 2) {
                ForEach(0..<Int(geometry.size.height / 3), id: \.self) { _ in
                    Rectangle()
                        .fill(RetroTheme.scanlineColor)
                        .frame(height: 1)
                    Spacer()
                        .frame(height: 2)
                }
            }
        }
        .allowsHitTesting(false)
    }
}

// Glow effect modifier
struct GlowEffect: ViewModifier {
    var color: Color = RetroTheme.primaryGreen
    var radius: CGFloat = 10

    func body(content: Content) -> some View {
        content
            .shadow(color: color, radius: radius / 3)
            .shadow(color: color, radius: radius / 2)
            .shadow(color: color, radius: radius)
    }
}

extension View {
    func retroGlow(color: Color = RetroTheme.primaryGreen, radius: CGFloat = 10) -> some View {
        modifier(GlowEffect(color: color, radius: radius))
    }
}

// Retro border style
struct RetroBorder: ViewModifier {
    var color: Color = RetroTheme.primaryGreen

    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(color, lineWidth: 1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(color.opacity(0.5), lineWidth: 1)
                    .blur(radius: 2)
            )
    }
}

extension View {
    func retroBorder(color: Color = RetroTheme.primaryGreen) -> some View {
        modifier(RetroBorder(color: color))
    }
}
