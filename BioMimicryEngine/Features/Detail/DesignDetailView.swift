import SwiftUI
import SceneKit

struct DesignDetailView: View {
    let design: GeneratedDesign
    @Environment(\.dismiss) private var dismiss
    @State private var showingShareSheet = false
    @State private var shareURL: URL?
    @State private var mesh: MeshData?
    @State private var isExporting = false

    var body: some View {
        ZStack {
            RetroTheme.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                headerSection

                ScrollView {
                    VStack(spacing: 16) {
                        // 3D Preview
                        previewSection

                        // Generation info
                        generationInfoSection

                        // Structural properties
                        propertiesSection

                        // Potential applications
                        applicationsSection

                        // Export section
                        exportSection
                    }
                    .padding()
                }
            }

            ScanlineOverlay()
                .ignoresSafeArea()
        }
        .onAppear {
            mesh = design.regenerateMesh()
        }
        .sheet(isPresented: $showingShareSheet) {
            if let url = shareURL {
                ShareSheet(items: [url])
            }
        }
    }

    private var headerSection: some View {
        HStack {
            Button(action: { dismiss() }) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                    TerminalText(text: "BACK", size: 14)
                }
            }

            Spacer()

            RetroHeader(text: design.displayName, size: 16)

            Spacer()

            // Save button
            Button(action: saveDesign) {
                Image(systemName: "square.and.arrow.down")
                    .font(.system(size: 18))
                    .foregroundColor(RetroTheme.primaryGreen)
            }
        }
        .padding()
    }

    private var previewSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            TerminalText(text: "3D PREVIEW", size: 12, color: RetroTheme.dimGreen)

            DesignPreviewView(design: design, mesh: mesh)
                .frame(height: 200)
                .retroBorder()
        }
    }

    private var generationInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            TerminalText(text: "GENERATION INFO", size: 12, color: RetroTheme.dimGreen)

            RetroInfoCard(
                title: "Algorithm",
                content: design.algorithmName,
                icon: "cpu"
            )

            RetroInfoCard(
                title: "Description",
                content: design.algorithmDescription,
                icon: "text.alignleft"
            )

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    TerminalText(text: "SEED", size: 10, color: RetroTheme.darkGreen)
                    TerminalText(text: design.seedString, size: 14)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(10)
                .retroBorder(color: RetroTheme.darkGreen)

                VStack(alignment: .leading, spacing: 4) {
                    TerminalText(text: "CREATED", size: 10, color: RetroTheme.darkGreen)
                    TerminalText(text: design.dateString, size: 12)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(10)
                .retroBorder(color: RetroTheme.darkGreen)
            }
        }
    }

    private var propertiesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            TerminalText(text: "STRUCTURAL PROPERTIES", size: 12, color: RetroTheme.dimGreen)

            let props = design.properties

            RetroProgressBar(progress: props.porosity, label: "POROSITY")
            RetroProgressBar(progress: min(props.surfaceToVolumeRatio / 10, 1), label: "SURFACE/VOLUME RATIO")
            RetroProgressBar(progress: props.complexity, label: "COMPLEXITY")

            RetroInfoCard(
                title: "Characteristics",
                content: props.characteristicsDescription,
                icon: "cube"
            )

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    TerminalText(text: "TRIANGLES", size: 10, color: RetroTheme.darkGreen)
                    TerminalText(text: "\(props.triangleCount)", size: 14)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(10)
                .retroBorder(color: RetroTheme.darkGreen)

                VStack(alignment: .leading, spacing: 4) {
                    TerminalText(text: "VERTICES", size: 10, color: RetroTheme.darkGreen)
                    TerminalText(text: "\(props.vertexCount)", size: 14)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(10)
                .retroBorder(color: RetroTheme.darkGreen)
            }
        }
    }

    private var applicationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            TerminalText(text: "POTENTIAL APPLICATIONS", size: 12, color: RetroTheme.dimGreen)

            ForEach(design.properties.potentialApplications, id: \.self) { app in
                HStack(alignment: .top, spacing: 12) {
                    TerminalText(text: ">>", size: 12, color: RetroTheme.dimGreen)
                    TerminalText(text: app, size: 13)
                }
            }
        }
    }

    private var exportSection: some View {
        VStack(spacing: 12) {
            TerminalText(text: "EXPORT OPTIONS", size: 12, color: RetroTheme.dimGreen)

            HStack(spacing: 12) {
                RetroButton(title: "EXPORT STL", action: exportSTL, isLoading: isExporting)

                Button(action: copyDetails) {
                    HStack(spacing: 4) {
                        Image(systemName: "doc.on.doc")
                        TerminalText(text: "COPY INFO", size: 12)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .retroBorder()
                }
            }

            TerminalText(
                text: "STL files can be 3D printed at home, makerspaces, or online services",
                size: 11,
                color: RetroTheme.dimGreen
            )
            .multilineTextAlignment(.center)
        }
    }

    private func saveDesign() {
        StorageService.shared.save(design)
    }

    private func exportSTL() {
        isExporting = true

        Task.detached { [design] in
            let url = STLExporter.shared.exportSTL(design: design)

            await MainActor.run {
                isExporting = false
                if let url = url {
                    shareURL = url
                    showingShareSheet = true
                }
            }
        }
    }

    private func copyDetails() {
        let props = design.properties
        let details = """
        NOVEL DESIGN: \(design.displayName)
        Algorithm: \(design.algorithmName)
        Seed: \(design.seedString)

        STRUCTURAL PROPERTIES:
        - Porosity: \(props.porosityPercent)
        - Surface/Volume Ratio: \(props.surfaceToVolumeFormatted)
        - Complexity: \(props.complexityLevel)
        - Symmetry: \(props.symmetryType)
        - Triangles: \(props.triangleCount)
        - Vertices: \(props.vertexCount)

        CHARACTERISTICS:
        \(props.characteristicsDescription)

        POTENTIAL APPLICATIONS:
        \(props.potentialApplications.map { "- \($0)" }.joined(separator: "\n"))

        Generated: \(design.dateString)
        """

        UIPasteboard.general.string = details
    }
}

// Preview view for the detail screen
struct DesignPreviewView: UIViewRepresentable {
    let design: GeneratedDesign
    let mesh: MeshData?

    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.backgroundColor = UIColor(red: 0.02, green: 0.02, blue: 0.02, alpha: 1)
        scnView.autoenablesDefaultLighting = false
        scnView.allowsCameraControl = true

        let scene = SCNScene()
        scnView.scene = scene

        // Camera
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 1.5, y: 1.2, z: 1.5)
        cameraNode.look(at: SCNVector3(0, 0, 0))
        scene.rootNode.addChildNode(cameraNode)

        // Lighting
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.color = UIColor(red: 0, green: 0.3, blue: 0.1, alpha: 1)
        ambientLight.light?.intensity = 500
        scene.rootNode.addChildNode(ambientLight)

        let directionalLight = SCNNode()
        directionalLight.light = SCNLight()
        directionalLight.light?.type = .directional
        directionalLight.light?.color = UIColor(red: 0, green: 1, blue: 0.4, alpha: 1)
        directionalLight.light?.intensity = 800
        directionalLight.position = SCNVector3(5, 10, 5)
        scene.rootNode.addChildNode(directionalLight)

        return scnView
    }

    func updateUIView(_ scnView: SCNView, context: Context) {
        guard let scene = scnView.scene, let mesh = mesh else { return }

        scene.rootNode.childNode(withName: "model", recursively: false)?.removeFromParentNode()

        let geometry = NovelGenerator.shared.generateGeometry(mesh: mesh)
        let modelNode = SCNNode(geometry: geometry)
        modelNode.name = "model"

        let rotation = SCNAction.rotateBy(x: 0, y: CGFloat.pi * 2, z: 0, duration: 20)
        modelNode.runAction(SCNAction.repeatForever(rotation))

        scene.rootNode.addChildNode(modelNode)
    }
}

#Preview {
    DesignDetailView(design: GeneratedDesign(
        seed: 123456,
        algorithm: .noiseField,
        complexity: 0.5,
        density: 0.5,
        organicBias: 0.5,
        properties: .placeholder
    ))
}
