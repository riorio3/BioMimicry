import SwiftUI

// Terminal-style text
struct TerminalText: View {
    let text: String
    var size: CGFloat = 14
    var color: Color = RetroTheme.primaryGreen

    var body: some View {
        Text(text)
            .font(RetroTheme.terminalFont(size))
            .foregroundColor(color)
    }
}

// Header text with glow
struct RetroHeader: View {
    let text: String
    var size: CGFloat = 24

    var body: some View {
        Text(text)
            .font(RetroTheme.headerFont(size))
            .foregroundColor(RetroTheme.primaryGreen)
            .retroGlow(radius: 8)
    }
}

// Retro-styled button
struct RetroButton: View {
    let title: String
    let action: () -> Void
    var isLoading: Bool = false

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: RetroTheme.background))
                        .scaleEffect(0.8)
                } else {
                    Text("[ \(title) ]")
                        .font(RetroTheme.terminalFont(12))
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                }
            }
            .foregroundColor(isPressed ? RetroTheme.background : RetroTheme.primaryGreen)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(isPressed ? RetroTheme.primaryGreen : Color.clear)
            )
            .retroBorder()
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
        .retroGlow(radius: isPressed ? 15 : 5)
    }
}

// Progress bar
struct RetroProgressBar: View {
    let progress: Double
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                TerminalText(text: label, size: 12, color: RetroTheme.dimGreen)
                Spacer()
                TerminalText(text: "\(Int(progress * 100))%", size: 12)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(RetroTheme.darkGreen)
                        .frame(height: 8)

                    Rectangle()
                        .fill(RetroTheme.primaryGreen)
                        .frame(width: geometry.size.width * progress, height: 8)
                        .retroGlow(radius: 4)
                }
            }
            .frame(height: 8)
            .retroBorder()
        }
    }
}

// Info card for biomimicry details
struct RetroInfoCard: View {
    let title: String
    let content: String
    var icon: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                if let icon = icon {
                    Image(systemName: icon)
                        .foregroundColor(RetroTheme.primaryGreen)
                        .font(.system(size: 14))
                }
                TerminalText(text: title.uppercased(), size: 12, color: RetroTheme.dimGreen)
            }

            TerminalText(text: content, size: 14)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RetroTheme.darkGreen.opacity(0.3))
        .retroBorder(color: RetroTheme.dimGreen)
    }
}

// Animated typing text effect
struct TypewriterText: View {
    let text: String
    @State private var displayedText = ""
    @State private var currentIndex = 0

    var body: some View {
        TerminalText(text: displayedText + (currentIndex < text.count ? "_" : ""))
            .onAppear {
                startTyping()
            }
    }

    private func startTyping() {
        displayedText = ""
        currentIndex = 0

        Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { timer in
            if currentIndex < text.count {
                let index = text.index(text.startIndex, offsetBy: currentIndex)
                displayedText += String(text[index])
                currentIndex += 1
            } else {
                timer.invalidate()
            }
        }
    }
}

#Preview {
    ZStack {
        RetroTheme.background.ignoresSafeArea()

        VStack(spacing: 20) {
            RetroHeader(text: "BIOMIMICRY ENGINE")

            RetroButton(title: "GENERATE", action: {})

            RetroProgressBar(progress: 0.72, label: "STRENGTH")

            RetroInfoCard(
                title: "Biological Source",
                content: "Honeybee wax comb structures",
                icon: "leaf"
            )
        }
        .padding()
    }
}
