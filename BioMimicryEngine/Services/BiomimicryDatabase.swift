import Foundation

class BiomimicryDatabase {
    static let shared = BiomimicryDatabase()

    private init() {}

    func getPattern(for type: PatternType) -> BiomimicryPattern {
        switch type {
        case .honeycomb: return .honeycomb
        case .voronoi: return .voronoi
        case .branching: return .branching
        case .spiral: return .spiral
        case .gyroid: return .gyroid
        }
    }

    func getAllPatterns() -> [BiomimicryPattern] {
        BiomimicryPattern.allPatterns
    }

    func getRandomPattern() -> BiomimicryPattern {
        BiomimicryPattern.allPatterns.randomElement() ?? .honeycomb
    }

    func getDetailedDescription(for pattern: BiomimicryPattern) -> String {
        switch pattern.type {
        case .honeycomb:
            return """
            The honeycomb structure is nature's answer to efficient space-filling. \
            Bees evolved this hexagonal pattern because it uses the least amount of wax \
            to create the most storage space. Each cell shares walls with six neighbors, \
            distributing load evenly across the structure.
            """

        case .voronoi:
            return """
            Voronoi patterns emerge when space is divided based on proximity to seed points. \
            Found in giraffe skin, dragonfly wings, and soap bubbles, this pattern \
            naturally distributes stress and adapts to irregular boundaries. \
            Each cell grows until it meets its neighbors.
            """

        case .branching:
            return """
            Branching networks follow Murray's Law - the principle that biological \
            transport systems minimize the energy required to move fluids. \
            From tree roots to blood vessels, this fractal pattern ensures efficient \
            distribution from a single source to many endpoints.
            """

        case .spiral:
            return """
            The Fibonacci spiral appears throughout nature - in nautilus shells, \
            sunflower seed arrangements, and galaxy formations. This golden ratio \
            pattern allows for continuous growth without changing shape, \
            maximizing packing efficiency and structural integrity.
            """

        case .gyroid:
            return """
            The gyroid is a triply periodic minimal surface - a complex 3D structure \
            with zero mean curvature everywhere. Found in butterfly wing scales, \
            it creates an interconnected network that maximizes surface area \
            while maintaining incredible strength-to-weight ratios.
            """
        }
    }

    func getEngineeringApplications(for pattern: BiomimicryPattern) -> [EngineeringApplication] {
        switch pattern.type {
        case .honeycomb:
            return [
                EngineeringApplication(field: "Aerospace", description: "Lightweight sandwich panels for aircraft floors and walls"),
                EngineeringApplication(field: "Automotive", description: "Crash-absorbing bumper structures"),
                EngineeringApplication(field: "Construction", description: "Thermal insulation panels")
            ]

        case .voronoi:
            return [
                EngineeringApplication(field: "Medical", description: "Bone implant scaffolds that promote cell growth"),
                EngineeringApplication(field: "Architecture", description: "Organic-looking facade panels"),
                EngineeringApplication(field: "Sports", description: "Helmet padding for impact distribution")
            ]

        case .branching:
            return [
                EngineeringApplication(field: "Electronics", description: "Heat dissipation networks in CPUs"),
                EngineeringApplication(field: "HVAC", description: "Efficient air distribution ductwork"),
                EngineeringApplication(field: "Urban Planning", description: "Optimized road and utility networks")
            ]

        case .spiral:
            return [
                EngineeringApplication(field: "Energy", description: "More efficient wind turbine blade designs"),
                EngineeringApplication(field: "Manufacturing", description: "Mixing chamber optimization"),
                EngineeringApplication(field: "Architecture", description: "Self-supporting spiral staircases")
            ]

        case .gyroid:
            return [
                EngineeringApplication(field: "Biomedical", description: "Tissue engineering scaffolds"),
                EngineeringApplication(field: "Energy Storage", description: "High surface area battery electrodes"),
                EngineeringApplication(field: "Thermal", description: "Compact heat exchangers")
            ]
        }
    }
}

struct EngineeringApplication: Identifiable {
    let id = UUID()
    let field: String
    let description: String
}
