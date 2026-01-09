import SwiftUI
import SceneKit

struct GalleryView: View {
    @StateObject private var viewModel = GalleryViewModel()

    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ZStack {
            RetroTheme.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                headerSection

                if viewModel.designs.isEmpty {
                    emptyState
                } else {
                    galleryGrid
                }
            }

            ScanlineOverlay()
                .ignoresSafeArea()
        }
        .sheet(item: $viewModel.selectedDesign) { design in
            DesignDetailView(design: design)
        }
        .onAppear {
            viewModel.loadDesigns()
        }
    }

    private var headerSection: some View {
        HStack {
            RetroHeader(text: "DESIGN GALLERY", size: 18)
            Spacer()
            TerminalText(text: "\(viewModel.designs.count) DESIGNS", size: 12, color: RetroTheme.dimGreen)
        }
        .padding()
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "square.grid.2x2")
                .font(.system(size: 50))
                .foregroundColor(RetroTheme.dimGreen)

            VStack(spacing: 8) {
                TerminalText(text: "NO SAVED DESIGNS", size: 16)
                TerminalText(text: "Generate and save designs to see them here", size: 12, color: RetroTheme.dimGreen)
            }

            Spacer()
        }
    }

    private var galleryGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(viewModel.designs) { design in
                    GalleryCard(design: design) {
                        viewModel.selectDesign(design)
                    }
                    .contextMenu {
                        Button(role: .destructive) {
                            viewModel.deleteDesign(design)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .padding()
        }
    }
}

struct GalleryCard: View {
    let design: GeneratedDesign
    let action: () -> Void
    @State private var mesh: MeshData?

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                // Mini 3D preview
                GalleryPreviewView(design: design, mesh: mesh)
                    .frame(height: 120)
                    .allowsHitTesting(false)

                VStack(alignment: .leading, spacing: 4) {
                    TerminalText(text: design.displayName, size: 11)

                    HStack {
                        TerminalText(text: design.algorithmName.prefix(10).uppercased(), size: 9, color: RetroTheme.dimGreen)
                        Spacer()
                        TerminalText(text: design.properties.porosityPercent, size: 9, color: RetroTheme.dimGreen)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
            }
            .background(RetroTheme.darkGreen.opacity(0.2))
            .retroBorder()
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            // Generate mesh in background
            DispatchQueue.global(qos: .userInitiated).async {
                let generatedMesh = design.regenerateMesh()
                DispatchQueue.main.async {
                    self.mesh = generatedMesh
                }
            }
        }
    }
}

struct GalleryPreviewView: UIViewRepresentable {
    let design: GeneratedDesign
    let mesh: MeshData?

    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.backgroundColor = UIColor(red: 0.02, green: 0.02, blue: 0.02, alpha: 1)
        scnView.autoenablesDefaultLighting = false
        scnView.allowsCameraControl = false

        let scene = SCNScene()
        scnView.scene = scene

        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 1.5, y: 1.2, z: 1.5)
        cameraNode.look(at: SCNVector3(0, 0, 0))
        scene.rootNode.addChildNode(cameraNode)

        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.color = UIColor(red: 0, green: 0.3, blue: 0.1, alpha: 1)
        ambientLight.light?.intensity = 500
        scene.rootNode.addChildNode(ambientLight)

        return scnView
    }

    func updateUIView(_ scnView: SCNView, context: Context) {
        guard let scene = scnView.scene, let mesh = mesh else { return }

        scene.rootNode.childNode(withName: "model", recursively: false)?.removeFromParentNode()

        let geometry = NovelGenerator.shared.generateGeometry(mesh: mesh)
        let modelNode = SCNNode(geometry: geometry)
        modelNode.name = "model"

        scene.rootNode.addChildNode(modelNode)
    }
}

#Preview {
    GalleryView()
}
