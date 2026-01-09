import SwiftUI
import SceneKit

// Preview placeholder when no design is loaded
struct EmptySceneView: View {
    @State private var opacity: Double = 0.5

    var body: some View {
        ZStack {
            RetroTheme.background

            VStack(spacing: 20) {
                Image(systemName: "cube.transparent")
                    .font(.system(size: 60))
                    .foregroundColor(RetroTheme.dimGreen)
                    .opacity(opacity)

                TerminalText(text: "NO DESIGN LOADED", size: 14, color: RetroTheme.dimGreen)
                    .opacity(opacity)

                TerminalText(text: "TAP GENERATE TO BEGIN", size: 12, color: RetroTheme.darkGreen)
                    .opacity(opacity)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                opacity = 1.0
            }
        }
    }
}

#Preview {
    ZStack {
        RetroTheme.background.ignoresSafeArea()
        EmptySceneView()
    }
}
