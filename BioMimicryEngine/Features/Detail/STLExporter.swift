import Foundation
import SceneKit
import SwiftUI
import UIKit

class STLExporter {
    static let shared = STLExporter()

    private init() {}

    func exportSTL(design: GeneratedDesign) -> URL? {
        let mesh = design.regenerateMesh()
        let stlContent = generateSTLContent(mesh: mesh, name: design.name)

        let fileName = "\(design.name).stl"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        do {
            try stlContent.write(to: tempURL, atomically: true, encoding: .ascii)
            return tempURL
        } catch {
            print("Error writing STL file: \(error)")
            return nil
        }
    }

    func exportSTL(mesh: MeshData, name: String) -> URL? {
        let stlContent = generateSTLContent(mesh: mesh, name: name)

        let fileName = "\(name).stl"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        do {
            try stlContent.write(to: tempURL, atomically: true, encoding: .ascii)
            return tempURL
        } catch {
            print("Error writing STL file: \(error)")
            return nil
        }
    }

    private func generateSTLContent(mesh: MeshData, name: String) -> String {
        let triangleCount = mesh.indices.count / 3

        var lines: [String] = []
        lines.reserveCapacity(triangleCount * 7 + 2)

        lines.append("solid \(name)")

        for i in 0..<triangleCount {
            let idx0 = Int(mesh.indices[i * 3])
            let idx1 = Int(mesh.indices[i * 3 + 1])
            let idx2 = Int(mesh.indices[i * 3 + 2])

            guard idx0 < mesh.vertices.count,
                  idx1 < mesh.vertices.count,
                  idx2 < mesh.vertices.count else { continue }

            let v0 = mesh.vertices[idx0]
            let v1 = mesh.vertices[idx1]
            let v2 = mesh.vertices[idx2]

            let normal = calculateNormal(v0: v0, v1: v1, v2: v2)

            lines.append("  facet normal \(formatFloat(normal.x)) \(formatFloat(normal.y)) \(formatFloat(normal.z))")
            lines.append("    outer loop")
            lines.append("      vertex \(formatFloat(v0.x)) \(formatFloat(v0.y)) \(formatFloat(v0.z))")
            lines.append("      vertex \(formatFloat(v1.x)) \(formatFloat(v1.y)) \(formatFloat(v1.z))")
            lines.append("      vertex \(formatFloat(v2.x)) \(formatFloat(v2.y)) \(formatFloat(v2.z))")
            lines.append("    endloop")
            lines.append("  endfacet")
        }

        lines.append("endsolid \(name)")

        return lines.joined(separator: "\n")
    }

    private func calculateNormal(v0: SCNVector3, v1: SCNVector3, v2: SCNVector3) -> SCNVector3 {
        let edge1 = SCNVector3(v1.x - v0.x, v1.y - v0.y, v1.z - v0.z)
        let edge2 = SCNVector3(v2.x - v0.x, v2.y - v0.y, v2.z - v0.z)

        var normal = SCNVector3(
            edge1.y * edge2.z - edge1.z * edge2.y,
            edge1.z * edge2.x - edge1.x * edge2.z,
            edge1.x * edge2.y - edge1.y * edge2.x
        )

        let length = sqrt(normal.x * normal.x + normal.y * normal.y + normal.z * normal.z)
        if length > 0 {
            normal = SCNVector3(normal.x / length, normal.y / length, normal.z / length)
        }

        return normal
    }

    private func formatFloat(_ value: Float) -> String {
        String(format: "%.6f", value)
    }
}

// SwiftUI wrapper for sharing
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
