import Foundation
import SceneKit

struct GeneratedDesign: Identifiable, Codable {
    let id: UUID
    let createdAt: Date
    var name: String

    // Generation parameters
    let seed: Int
    let algorithm: GenerationAlgorithm
    let complexity: Double
    let density: Double
    let organicBias: Double

    // Calculated properties
    let properties: StructuralProperties

    init(
        seed: Int,
        algorithm: GenerationAlgorithm,
        complexity: Double,
        density: Double,
        organicBias: Double,
        properties: StructuralProperties
    ) {
        self.id = UUID()
        self.createdAt = Date()
        self.seed = seed
        self.algorithm = algorithm
        self.complexity = complexity
        self.density = density
        self.organicBias = organicBias
        self.properties = properties
        self.name = "DESIGN_\(Self.generateShortId())"
    }

    static func generateShortId() -> String {
        let chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<6).map { _ in chars.randomElement()! })
    }

    var displayName: String {
        name.uppercased()
    }

    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd HH:mm"
        return formatter.string(from: createdAt)
    }

    var seedString: String {
        String(format: "%06d", seed % 1000000)
    }

    var algorithmName: String {
        algorithm.rawValue
    }

    var algorithmDescription: String {
        algorithm.description
    }

    // Regenerate the same design using stored parameters
    func regenerateMesh() -> MeshData {
        let result = NovelGenerator.shared.generate(
            seed: seed,
            complexity: complexity,
            density: density,
            organicBias: organicBias,
            algorithm: algorithm
        )
        return result.mesh
    }
}

// Make equatable for SwiftUI
extension GeneratedDesign: Equatable {
    static func == (lhs: GeneratedDesign, rhs: GeneratedDesign) -> Bool {
        lhs.id == rhs.id
    }
}

// Mesh data for STL export
struct MeshData {
    var vertices: [SCNVector3]
    var indices: [Int32]
    var normals: [SCNVector3]

    init() {
        vertices = []
        indices = []
        normals = []
    }

    mutating func addTriangle(_ v1: SCNVector3, _ v2: SCNVector3, _ v3: SCNVector3) {
        let baseIndex = Int32(vertices.count)

        vertices.append(v1)
        vertices.append(v2)
        vertices.append(v3)

        indices.append(baseIndex)
        indices.append(baseIndex + 1)
        indices.append(baseIndex + 2)

        // Calculate normal
        let edge1 = SCNVector3(v2.x - v1.x, v2.y - v1.y, v2.z - v1.z)
        let edge2 = SCNVector3(v3.x - v1.x, v3.y - v1.y, v3.z - v1.z)
        let normal = SCNVector3(
            edge1.y * edge2.z - edge1.z * edge2.y,
            edge1.z * edge2.x - edge1.x * edge2.z,
            edge1.x * edge2.y - edge1.y * edge2.x
        )

        normals.append(normal)
        normals.append(normal)
        normals.append(normal)
    }
}
