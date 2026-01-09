import Foundation

struct StructuralProperties: Codable {
    let surfaceArea: Double
    let boundingVolume: Double
    let surfaceToVolumeRatio: Double
    let porosity: Double
    let complexity: Double
    let symmetryType: String
    let triangleCount: Int
    let vertexCount: Int

    var porosityPercent: String {
        String(format: "%.0f%%", porosity * 100)
    }

    var surfaceToVolumeFormatted: String {
        String(format: "%.2f", surfaceToVolumeRatio)
    }

    var complexityLevel: String {
        if complexity < 0.3 {
            return "Low"
        } else if complexity < 0.6 {
            return "Medium"
        } else {
            return "High"
        }
    }

    var meshStats: String {
        "\(triangleCount) triangles, \(vertexCount) vertices"
    }

    // Potential applications based on properties
    var potentialApplications: [String] {
        var apps: [String] = []

        if porosity > 0.5 {
            apps.append("Filtration systems")
            apps.append("Acoustic dampening")
        }

        if surfaceToVolumeRatio > 5 {
            apps.append("Heat exchangers")
            apps.append("Catalyst supports")
        }

        if complexity > 0.6 {
            apps.append("Lightweight structural components")
            apps.append("Energy absorption")
        }

        if porosity < 0.3 && complexity < 0.4 {
            apps.append("Load-bearing structures")
            apps.append("Protective housings")
        }

        if surfaceToVolumeRatio > 3 && porosity > 0.4 {
            apps.append("Tissue scaffolds")
            apps.append("Drug delivery systems")
        }

        if apps.isEmpty {
            apps.append("General structural applications")
            apps.append("Decorative/artistic use")
        }

        return Array(apps.prefix(4))
    }

    // Structural characteristics description
    var characteristicsDescription: String {
        var desc: [String] = []

        if porosity > 0.6 {
            desc.append("Highly porous")
        } else if porosity > 0.3 {
            desc.append("Moderately porous")
        } else {
            desc.append("Dense")
        }

        if surfaceToVolumeRatio > 5 {
            desc.append("high surface area")
        }

        if complexity > 0.6 {
            desc.append("complex geometry")
        } else if complexity < 0.3 {
            desc.append("simple geometry")
        }

        desc.append(symmetryType.lowercased())

        return desc.joined(separator: ", ").capitalized + " structure"
    }

    static let placeholder = StructuralProperties(
        surfaceArea: 0,
        boundingVolume: 0,
        surfaceToVolumeRatio: 0,
        porosity: 0,
        complexity: 0,
        symmetryType: "Unknown",
        triangleCount: 0,
        vertexCount: 0
    )
}
