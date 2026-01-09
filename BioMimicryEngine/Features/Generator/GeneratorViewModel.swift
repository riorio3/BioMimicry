import Foundation
import SwiftUI
import SceneKit

@MainActor
class GeneratorViewModel: ObservableObject {
    @Published var currentDesign: GeneratedDesign?
    @Published var currentMesh: MeshData?
    @Published var isGenerating: Bool = false
    @Published var isRotating: Bool = true
    @Published var showingDetail: Bool = false
    @Published var showingShareSheet: Bool = false
    @Published var shareURL: URL?

    // Generation parameters
    @Published var complexity: Double = 0.5
    @Published var density: Double = 0.5
    @Published var organicBias: Double = 0.5

    private let generator = NovelGenerator.shared
    private let storage = StorageService.shared

    var currentProperties: StructuralProperties? {
        currentDesign?.properties
    }

    func generate() {
        isGenerating = true

        // Use background thread for generation
        Task {
            let seed = Int.random(in: 0...999999)

            let result = generator.generate(
                seed: seed,
                complexity: complexity,
                density: density,
                organicBias: organicBias
            )

            await MainActor.run {
                self.currentMesh = result.mesh

                self.currentDesign = GeneratedDesign(
                    seed: seed,
                    algorithm: result.algorithm,
                    complexity: self.complexity,
                    density: self.density,
                    organicBias: self.organicBias,
                    properties: result.properties
                )

                self.isGenerating = false
            }
        }
    }

    func generateWithSeed(_ seed: Int) {
        isGenerating = true

        Task {
            let result = generator.generate(
                seed: seed,
                complexity: complexity,
                density: density,
                organicBias: organicBias
            )

            await MainActor.run {
                self.currentMesh = result.mesh

                self.currentDesign = GeneratedDesign(
                    seed: seed,
                    algorithm: result.algorithm,
                    complexity: self.complexity,
                    density: self.density,
                    organicBias: self.organicBias,
                    properties: result.properties
                )

                self.isGenerating = false
            }
        }
    }

    func saveCurrentDesign() {
        guard let design = currentDesign else { return }
        storage.save(design)
    }

    func exportSTL() {
        guard let design = currentDesign else { return }

        isGenerating = true

        Task.detached { [weak self] in
            let url = STLExporter.shared.exportSTL(design: design)

            await MainActor.run {
                self?.isGenerating = false
                if let url = url {
                    self?.shareURL = url
                    self?.showingShareSheet = true
                }
            }
        }
    }

    func generateGeometry() -> SCNGeometry? {
        guard let mesh = currentMesh else { return nil }
        return generator.generateGeometry(mesh: mesh)
    }
}
