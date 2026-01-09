import Foundation

enum PatternType: String, Codable, CaseIterable {
    case honeycomb = "honeycomb"
    case voronoi = "voronoi"
    case branching = "branching"
    case spiral = "spiral"
    case gyroid = "gyroid"
}

struct BiomimicryPattern: Identifiable, Codable {
    let id: String
    let type: PatternType
    let name: String
    let biologicalSource: String
    let principle: String
    let useCases: [String]
    let strengthRating: Double
    let weightEfficiency: Double
    let complexity: Double

    static let honeycomb = BiomimicryPattern(
        id: "honeycomb",
        type: .honeycomb,
        name: "Honeycomb",
        biologicalSource: "Bee wax comb structures",
        principle: "Maximum strength with minimum material through hexagonal tessellation",
        useCases: ["Aerospace panels", "Packaging materials", "Building insulation", "Crash absorption"],
        strengthRating: 0.85,
        weightEfficiency: 0.92,
        complexity: 0.4
    )

    static let voronoi = BiomimicryPattern(
        id: "voronoi",
        type: .voronoi,
        name: "Voronoi",
        biologicalSource: "Cell structures, giraffe skin patterns, dragonfly wings",
        principle: "Organic cell-like distribution for impact absorption and load spreading",
        useCases: ["Impact protection", "Lightweight structures", "Architectural facades", "Medical implants"],
        strengthRating: 0.78,
        weightEfficiency: 0.88,
        complexity: 0.6
    )

    static let branching = BiomimicryPattern(
        id: "branching",
        type: .branching,
        name: "Branching",
        biologicalSource: "Tree vascular systems, blood vessels, river deltas",
        principle: "Hierarchical branching for efficient flow distribution and resource transport",
        useCases: ["Cooling systems", "Fluid distribution", "Electrical networks", "Drainage systems"],
        strengthRating: 0.65,
        weightEfficiency: 0.75,
        complexity: 0.7
    )

    static let spiral = BiomimicryPattern(
        id: "spiral",
        type: .spiral,
        name: "Spiral",
        biologicalSource: "Nautilus shells, sunflower seeds, hurricanes",
        principle: "Fibonacci growth patterns for efficient packing and structural stability",
        useCases: ["Turbine blades", "Antenna design", "Mixing chambers", "Staircase structures"],
        strengthRating: 0.72,
        weightEfficiency: 0.80,
        complexity: 0.5
    )

    static let gyroid = BiomimicryPattern(
        id: "gyroid",
        type: .gyroid,
        name: "Gyroid",
        biologicalSource: "Butterfly wing scales, sea urchin skeletons",
        principle: "Triply periodic minimal surface for maximum strength-to-weight ratio",
        useCases: ["Bone scaffolds", "Heat exchangers", "Battery electrodes", "Soundproofing"],
        strengthRating: 0.90,
        weightEfficiency: 0.95,
        complexity: 0.9
    )

    static let allPatterns: [BiomimicryPattern] = [
        .honeycomb, .voronoi, .branching, .spiral, .gyroid
    ]
}
