import SwiftUI
import SceneKit

struct GeneratorView: View {
    @StateObject private var viewModel = GeneratorViewModel()

    var body: some View {
        ZStack {
            RetroTheme.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                headerSection

                // 3D View
                sceneSection

                // Properties display
                if let props = viewModel.currentProperties {
                    propertiesSection(props)
                }

                // Controls
                controlsSection
            }

            // Scanline overlay
            ScanlineOverlay()
                .ignoresSafeArea()
        }
        .sheet(isPresented: $viewModel.showingDetail) {
            if let design = viewModel.currentDesign {
                DesignDetailView(design: design)
            }
        }
        .sheet(isPresented: $viewModel.showingShareSheet) {
            if let url = viewModel.shareURL {
                ShareSheet(items: [url])
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 4) {
            HStack {
                RetroHeader(text: "BIOMIMICRY ENGINE", size: 18)
                Spacer()
                TerminalText(text: "v2.0", size: 12, color: RetroTheme.dimGreen)
            }

            HStack {
                if let design = viewModel.currentDesign {
                    TerminalText(text: design.algorithmName.uppercased(), size: 12, color: RetroTheme.dimGreen)
                    Spacer()
                    TerminalText(text: "SEED: \(design.seedString)", size: 12, color: RetroTheme.dimGreen)
                } else {
                    TerminalText(text: "READY TO GENERATE", size: 12, color: RetroTheme.dimGreen)
                    Spacer()
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }

    private var sceneSection: some View {
        ZStack {
            if viewModel.currentMesh != nil {
                SceneKitViewNovel(viewModel: viewModel)
            } else {
                EmptySceneView()
            }

            // Overlay controls
            VStack {
                HStack {
                    Spacer()

                    // Rotation toggle
                    Button(action: { viewModel.isRotating.toggle() }) {
                        Image(systemName: viewModel.isRotating ? "pause.circle" : "play.circle")
                            .font(.system(size: 24))
                            .foregroundColor(RetroTheme.primaryGreen)
                            .retroGlow(radius: 5)
                    }
                    .padding(8)
                }

                Spacer()

                // Info button when design exists
                if viewModel.currentDesign != nil {
                    HStack {
                        Button(action: { viewModel.showingDetail = true }) {
                            HStack(spacing: 4) {
                                Image(systemName: "info.circle")
                                TerminalText(text: "DETAILS", size: 12)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(RetroTheme.background.opacity(0.8))
                            .retroBorder()
                        }

                        Spacer()
                    }
                    .padding(8)
                }
            }
        }
        .frame(maxHeight: .infinity)
        .retroBorder()
        .padding(.horizontal)
    }

    private func propertiesSection(_ props: StructuralProperties) -> some View {
        VStack(spacing: 6) {
            HStack(spacing: 16) {
                propertyItem(label: "POROSITY", value: props.porosityPercent)
                propertyItem(label: "S/V RATIO", value: props.surfaceToVolumeFormatted)
                propertyItem(label: "COMPLEXITY", value: props.complexityLevel)
                propertyItem(label: "SYMMETRY", value: String(props.symmetryType.prefix(8)))
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }

    private func propertyItem(label: String, value: String) -> some View {
        VStack(spacing: 2) {
            TerminalText(text: label, size: 9, color: RetroTheme.darkGreen)
            TerminalText(text: value, size: 11, color: RetroTheme.primaryGreen)
        }
        .frame(maxWidth: .infinity)
    }

    private var controlsSection: some View {
        VStack(spacing: 12) {
            // Parameter sliders
            parameterSliders

            // Action buttons
            actionButtons
        }
        .padding()
    }

    private var parameterSliders: some View {
        VStack(spacing: 8) {
            // Complexity slider
            HStack {
                TerminalText(text: "COMPLEXITY", size: 10, color: RetroTheme.dimGreen)
                    .frame(width: 80, alignment: .leading)

                Slider(value: $viewModel.complexity, in: 0.1...1.0)
                    .accentColor(RetroTheme.primaryGreen)

                TerminalText(text: String(format: "%.0f%%", viewModel.complexity * 100), size: 10)
                    .frame(width: 35, alignment: .trailing)
            }

            // Density slider
            HStack {
                TerminalText(text: "DENSITY", size: 10, color: RetroTheme.dimGreen)
                    .frame(width: 80, alignment: .leading)

                Slider(value: $viewModel.density, in: 0.2...1.0)
                    .accentColor(RetroTheme.primaryGreen)

                TerminalText(text: String(format: "%.0f%%", viewModel.density * 100), size: 10)
                    .frame(width: 35, alignment: .trailing)
            }

            // Organic bias slider
            HStack {
                TerminalText(text: "GEOMETRIC", size: 10, color: RetroTheme.dimGreen)
                    .frame(width: 80, alignment: .leading)

                Slider(value: $viewModel.organicBias, in: 0.0...1.0)
                    .accentColor(RetroTheme.primaryGreen)

                TerminalText(text: "ORGANIC", size: 10, color: RetroTheme.dimGreen)
                    .frame(width: 50, alignment: .trailing)
            }
        }
        .padding(.horizontal, 4)
    }

    private var actionButtons: some View {
        HStack(spacing: 12) {
            // Save button
            Button(action: viewModel.saveCurrentDesign) {
                HStack(spacing: 4) {
                    Image(systemName: "square.and.arrow.down")
                    TerminalText(text: "SAVE", size: 12)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .retroBorder(color: viewModel.currentDesign != nil ? RetroTheme.dimGreen : RetroTheme.darkGreen)
            }
            .disabled(viewModel.currentDesign == nil)
            .opacity(viewModel.currentDesign != nil ? 1 : 0.5)

            // Main generate button
            RetroButton(title: "GENERATE", action: viewModel.generate, isLoading: viewModel.isGenerating)

            // Export button
            Button(action: viewModel.exportSTL) {
                HStack(spacing: 4) {
                    Image(systemName: "cube.transparent")
                    TerminalText(text: "EXPORT", size: 12)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .retroBorder(color: viewModel.currentDesign != nil ? RetroTheme.primaryGreen : RetroTheme.darkGreen)
            }
            .disabled(viewModel.currentDesign == nil)
            .opacity(viewModel.currentDesign != nil ? 1 : 0.5)
        }
    }
}

// Updated SceneKit view that works with the new ViewModel
struct SceneKitViewNovel: UIViewRepresentable {
    @ObservedObject var viewModel: GeneratorViewModel

    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.backgroundColor = UIColor(red: 0.02, green: 0.02, blue: 0.02, alpha: 1)
        scnView.autoenablesDefaultLighting = false
        scnView.allowsCameraControl = true
        scnView.showsStatistics = false

        let scene = SCNScene()
        scnView.scene = scene

        setupCamera(in: scene)
        setupLighting(in: scene)
        addGridFloor(to: scene)

        context.coordinator.scnView = scnView

        // Add double-tap gesture to center view
        let doubleTap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleDoubleTap))
        doubleTap.numberOfTapsRequired = 2
        scnView.addGestureRecognizer(doubleTap)

        return scnView
    }

    func updateUIView(_ scnView: SCNView, context: Context) {
        guard let scene = scnView.scene else { return }

        // Remove old model
        scene.rootNode.childNode(withName: "model", recursively: false)?.removeFromParentNode()

        // Add new model if mesh exists
        if let geometry = viewModel.generateGeometry() {
            let modelNode = SCNNode(geometry: geometry)
            modelNode.name = "model"

            // Add rotation animation
            if viewModel.isRotating {
                let rotation = SCNAction.rotateBy(x: 0, y: CGFloat.pi * 2, z: 0, duration: 20)
                let repeatRotation = SCNAction.repeatForever(rotation)
                modelNode.runAction(repeatRotation, forKey: "rotation")
            } else {
                modelNode.removeAction(forKey: "rotation")
            }

            scene.rootNode.addChildNode(modelNode)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    private func setupCamera(in scene: SCNScene) {
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.zNear = 0.1
        cameraNode.camera?.zFar = 100
        cameraNode.position = SCNVector3(x: 1.5, y: 1.2, z: 1.5)
        cameraNode.look(at: SCNVector3(0, 0, 0))
        scene.rootNode.addChildNode(cameraNode)
    }

    private func setupLighting(in scene: SCNScene) {
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
        directionalLight.look(at: SCNVector3(0, 0, 0))
        scene.rootNode.addChildNode(directionalLight)
    }

    private func addGridFloor(to scene: SCNScene) {
        let gridSize: Float = 3.0
        let gridSpacing: Float = 0.2
        let gridColor = UIColor(red: 0, green: 0.3, blue: 0.12, alpha: 0.5)

        for i in stride(from: -gridSize, through: gridSize, by: gridSpacing) {
            let xLine = createLine(
                from: SCNVector3(-gridSize, -0.5, i),
                to: SCNVector3(gridSize, -0.5, i),
                color: gridColor
            )
            scene.rootNode.addChildNode(xLine)

            let zLine = createLine(
                from: SCNVector3(i, -0.5, -gridSize),
                to: SCNVector3(i, -0.5, gridSize),
                color: gridColor
            )
            scene.rootNode.addChildNode(zLine)
        }
    }

    private func createLine(from start: SCNVector3, to end: SCNVector3, color: UIColor) -> SCNNode {
        let indices: [Int32] = [0, 1]
        let source = SCNGeometrySource(vertices: [start, end])
        let element = SCNGeometryElement(indices: indices, primitiveType: .line)

        let geometry = SCNGeometry(sources: [source], elements: [element])
        let material = SCNMaterial()
        material.diffuse.contents = color
        material.emission.contents = color
        geometry.materials = [material]

        return SCNNode(geometry: geometry)
    }

    class Coordinator: NSObject {
        var scnView: SCNView?

        @objc func handleDoubleTap() {
            guard let scnView = scnView else { return }

            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5

            scnView.pointOfView?.position = SCNVector3(x: 1.5, y: 1.2, z: 1.5)
            scnView.pointOfView?.look(at: SCNVector3(0, 0, 0))

            SCNTransaction.commit()
        }
    }
}

#Preview {
    GeneratorView()
}
