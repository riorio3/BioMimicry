import SwiftUI

@main
struct BioMimicryEngineApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
                .preferredColorScheme(.dark)
        }
    }
}

struct MainView: View {
    @State private var selectedTab = 0

    var body: some View {
        ZStack {
            RetroTheme.background
                .ignoresSafeArea()

            TabView(selection: $selectedTab) {
                GeneratorView()
                    .tabItem {
                        Label("Generate", systemImage: "cube.transparent")
                    }
                    .tag(0)

                GalleryView()
                    .tabItem {
                        Label("Gallery", systemImage: "square.grid.2x2")
                    }
                    .tag(1)
            }
            .accentColor(RetroTheme.primaryGreen)
        }
    }
}

#Preview {
    MainView()
}
