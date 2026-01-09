import Foundation
import SceneKit

enum GenerationAlgorithm: String, CaseIterable, Codable {
    case noiseField = "Noise Field"
    case implicitBlend = "Implicit Blend"
    case reactionDiffusion = "Reaction-Diffusion"
    case randomLSystem = "L-System"
    case voronoiMutation = "Voronoi Mutation"

    var description: String {
        switch self {
        case .noiseField: return "Organic, cave-like porous structure"
        case .implicitBlend: return "Abstract mathematical surface"
        case .reactionDiffusion: return "Coral-like organic pattern"
        case .randomLSystem: return "Branching vascular network"
        case .voronoiMutation: return "Mutated cellular structure"
        }
    }
}

class NovelGenerator {
    static let shared = NovelGenerator()

    private init() {}

    // MARK: - Main Generation

    func generate(
        seed: Int,
        complexity: Double,
        density: Double,
        organicBias: Double,
        algorithm: GenerationAlgorithm? = nil
    ) -> (mesh: MeshData, properties: StructuralProperties, algorithm: GenerationAlgorithm) {
        srand48(seed)

        // Pick algorithm based on organic bias or use specified
        let selectedAlgorithm = algorithm ?? selectAlgorithm(organicBias: organicBias)

        let mesh: MeshData
        switch selectedAlgorithm {
        case .noiseField:
            mesh = generateNoiseField(complexity: complexity, density: density, seed: seed)
        case .implicitBlend:
            mesh = generateImplicitBlend(complexity: complexity, density: density, seed: seed)
        case .reactionDiffusion:
            mesh = generateReactionDiffusion(complexity: complexity, density: density, seed: seed)
        case .randomLSystem:
            mesh = generateRandomLSystem(complexity: complexity, density: density, seed: seed)
        case .voronoiMutation:
            mesh = generateVoronoiMutation(complexity: complexity, density: density, seed: seed)
        }

        let properties = calculateProperties(mesh: mesh)

        return (mesh, properties, selectedAlgorithm)
    }

    private func selectAlgorithm(organicBias: Double) -> GenerationAlgorithm {
        // Higher organic bias = more likely to get organic algorithms
        let organic: [GenerationAlgorithm] = [.noiseField, .reactionDiffusion, .randomLSystem]
        let geometric: [GenerationAlgorithm] = [.implicitBlend, .voronoiMutation]

        if drand48() < organicBias {
            return organic.randomElement() ?? .noiseField
        } else {
            return geometric.randomElement() ?? .implicitBlend
        }
    }

    func generateGeometry(mesh: MeshData) -> SCNGeometry {
        let vertexData = Data(bytes: mesh.vertices, count: mesh.vertices.count * MemoryLayout<SCNVector3>.size)
        let vertexSource = SCNGeometrySource(
            data: vertexData,
            semantic: .vertex,
            vectorCount: mesh.vertices.count,
            usesFloatComponents: true,
            componentsPerVector: 3,
            bytesPerComponent: MemoryLayout<Float>.size,
            dataOffset: 0,
            dataStride: MemoryLayout<SCNVector3>.size
        )

        let normalData = Data(bytes: mesh.normals, count: mesh.normals.count * MemoryLayout<SCNVector3>.size)
        let normalSource = SCNGeometrySource(
            data: normalData,
            semantic: .normal,
            vectorCount: mesh.normals.count,
            usesFloatComponents: true,
            componentsPerVector: 3,
            bytesPerComponent: MemoryLayout<Float>.size,
            dataOffset: 0,
            dataStride: MemoryLayout<SCNVector3>.size
        )

        let indexData = Data(bytes: mesh.indices, count: mesh.indices.count * MemoryLayout<Int32>.size)
        let element = SCNGeometryElement(
            data: indexData,
            primitiveType: .triangles,
            primitiveCount: mesh.indices.count / 3,
            bytesPerIndex: MemoryLayout<Int32>.size
        )

        let geometry = SCNGeometry(sources: [vertexSource, normalSource], elements: [element])

        let material = SCNMaterial()
        material.diffuse.contents = UIColor(red: 0, green: 1, blue: 0.4, alpha: 1)
        material.emission.contents = UIColor(red: 0, green: 0.5, blue: 0.2, alpha: 1)
        material.fillMode = .lines
        material.isDoubleSided = true
        geometry.materials = [material]

        return geometry
    }

    // MARK: - Algorithm 1: Noise Field (Perlin-like)

    private func generateNoiseField(complexity: Double, density: Double, seed: Int) -> MeshData {
        var mesh = MeshData()
        let resolution = Int(8 + complexity * 12)
        let scale = Float(0.8 + density * 0.4)
        let step = scale * 2.0 / Float(resolution)

        // Random noise parameters
        let freq1 = Float(2.0 + drand48() * 4.0)
        let freq2 = Float(1.0 + drand48() * 3.0)
        let freq3 = Float(0.5 + drand48() * 2.0)
        let amp1 = Float(0.3 + drand48() * 0.4)
        let amp2 = Float(0.2 + drand48() * 0.3)
        let amp3 = Float(0.1 + drand48() * 0.2)
        let threshold = Float(-0.1 + drand48() * 0.2)

        for xi in 0..<resolution {
            for yi in 0..<resolution {
                for zi in 0..<resolution {
                    let x = Float(xi) * step - scale
                    let y = Float(yi) * step - scale
                    let z = Float(zi) * step - scale

                    // Multi-octave noise function
                    let noise = perlinNoise3D(x * freq1, y * freq1, z * freq1, seed: seed) * amp1
                              + perlinNoise3D(x * freq2, y * freq2, z * freq2, seed: seed + 1) * amp2
                              + perlinNoise3D(x * freq3, y * freq3, z * freq3, seed: seed + 2) * amp3

                    // Sample at corners and create surface
                    if abs(noise - threshold) < 0.15 * Float(density) {
                        addCubeAt(to: &mesh, x: x, y: y, z: z, size: step * 0.8)
                    }
                }
            }
        }

        return mesh
    }

    private func perlinNoise3D(_ x: Float, _ y: Float, _ z: Float, seed: Int) -> Float {
        // Simplified Perlin-like noise
        let xi = Int(floor(x)) &+ seed
        let yi = Int(floor(y)) &+ seed
        let zi = Int(floor(z)) &+ seed

        let xf = x - floor(x)
        let yf = y - floor(y)
        let zf = z - floor(z)

        let u = fade(xf)
        let v = fade(yf)
        let w = fade(zf)

        let aaa = hash(xi, yi, zi)
        let aab = hash(xi, yi, zi + 1)
        let aba = hash(xi, yi + 1, zi)
        let abb = hash(xi, yi + 1, zi + 1)
        let baa = hash(xi + 1, yi, zi)
        let bab = hash(xi + 1, yi, zi + 1)
        let bba = hash(xi + 1, yi + 1, zi)
        let bbb = hash(xi + 1, yi + 1, zi + 1)

        var result = lerp(
            lerp(lerp(aaa, baa, u), lerp(aba, bba, u), v),
            lerp(lerp(aab, bab, u), lerp(abb, bbb, u), v),
            w
        )

        return result * 2.0 - 1.0
    }

    private func fade(_ t: Float) -> Float { t * t * t * (t * (t * 6 - 15) + 10) }
    private func lerp(_ a: Float, _ b: Float, _ t: Float) -> Float { a + t * (b - a) }
    private func hash(_ x: Int, _ y: Int, _ z: Int) -> Float {
        var h = x &* 374761393 &+ y &* 668265263 &+ z &* 1274126177
        h = (h ^ (h >> 13)) &* 1274126177
        return Float(h & 0x7FFFFFFF) / Float(0x7FFFFFFF)
    }

    // MARK: - Algorithm 2: Implicit Blend

    private func generateImplicitBlend(complexity: Double, density: Double, seed: Int) -> MeshData {
        var mesh = MeshData()
        let resolution = Int(10 + complexity * 10)
        let scale = Float(0.7 + density * 0.3)
        let step = scale * 2.0 / Float(resolution)

        // Random function parameters
        let params: [(Float, Float, Float, Float)] = (0..<4).map { _ in
            (Float(drand48() * 6 - 3),
             Float(drand48() * 6 - 3),
             Float(drand48() * 6 - 3),
             Float(drand48() * 2 - 1))
        }

        for xi in 0..<resolution {
            for yi in 0..<resolution {
                for zi in 0..<resolution {
                    let x = Float(xi) * step - scale
                    let y = Float(yi) * step - scale
                    let z = Float(zi) * step - scale

                    var value: Float = 0

                    // Blend multiple implicit functions
                    for (i, p) in params.enumerated() {
                        switch i % 4 {
                        case 0: value += sin(p.0 * x) * cos(p.1 * y) * p.3
                        case 1: value += sin(p.1 * y) * cos(p.2 * z) * p.3
                        case 2: value += sin(p.2 * z) * cos(p.0 * x) * p.3
                        case 3: value += sin(p.0 * x + p.1 * y) * cos(p.2 * z) * p.3
                        default: break
                        }
                    }

                    let threshold = Float(0.3 * density)
                    if abs(value) < threshold {
                        addCubeAt(to: &mesh, x: x, y: y, z: z, size: step * 0.85)
                    }
                }
            }
        }

        return mesh
    }

    // MARK: - Algorithm 3: Reaction-Diffusion

    private func generateReactionDiffusion(complexity: Double, density: Double, seed: Int) -> MeshData {
        var mesh = MeshData()
        let gridSize = Int(12 + complexity * 8)
        let scale = Float(0.8)
        let step = scale * 2.0 / Float(gridSize)

        // Initialize concentration grid
        var gridA = [[[Float]]](repeating: [[Float]](repeating: [Float](repeating: 1.0, count: gridSize), count: gridSize), count: gridSize)
        var gridB = [[[Float]]](repeating: [[Float]](repeating: [Float](repeating: 0.0, count: gridSize), count: gridSize), count: gridSize)

        // Seed some initial B concentration
        let numSeeds = Int(3 + density * 5)
        for _ in 0..<numSeeds {
            let sx = Int(drand48() * Double(gridSize - 4)) + 2
            let sy = Int(drand48() * Double(gridSize - 4)) + 2
            let sz = Int(drand48() * Double(gridSize - 4)) + 2
            for dx in -1...1 {
                for dy in -1...1 {
                    for dz in -1...1 {
                        gridB[sx + dx][sy + dy][sz + dz] = 1.0
                    }
                }
            }
        }

        // Reaction-diffusion parameters (Gray-Scott model)
        let dA: Float = 1.0
        let dB: Float = 0.5
        let feed = Float(0.055 + drand48() * 0.01)
        let kill = Float(0.062 + drand48() * 0.01)
        let iterations = Int(20 + complexity * 30)

        // Simulate
        for _ in 0..<iterations {
            var newA = gridA
            var newB = gridB

            for x in 1..<(gridSize - 1) {
                for y in 1..<(gridSize - 1) {
                    for z in 1..<(gridSize - 1) {
                        let a = gridA[x][y][z]
                        let b = gridB[x][y][z]

                        let laplaceA = laplacian3D(gridA, x, y, z)
                        let laplaceB = laplacian3D(gridB, x, y, z)

                        let reaction = a * b * b
                        newA[x][y][z] = a + (dA * laplaceA - reaction + feed * (1 - a)) * 0.1
                        newB[x][y][z] = b + (dB * laplaceB + reaction - (kill + feed) * b) * 0.1

                        newA[x][y][z] = max(0, min(1, newA[x][y][z]))
                        newB[x][y][z] = max(0, min(1, newB[x][y][z]))
                    }
                }
            }

            gridA = newA
            gridB = newB
        }

        // Extract surface where B is high
        let threshold = Float(0.2 + density * 0.2)
        for x in 0..<gridSize {
            for y in 0..<gridSize {
                for z in 0..<gridSize {
                    if gridB[x][y][z] > threshold {
                        let px = Float(x) * step - scale
                        let py = Float(y) * step - scale
                        let pz = Float(z) * step - scale
                        addCubeAt(to: &mesh, x: px, y: py, z: pz, size: step * 0.9)
                    }
                }
            }
        }

        return mesh
    }

    private func laplacian3D(_ grid: [[[Float]]], _ x: Int, _ y: Int, _ z: Int) -> Float {
        let center = grid[x][y][z]
        var sum: Float = 0
        sum += grid[x-1][y][z] + grid[x+1][y][z]
        sum += grid[x][y-1][z] + grid[x][y+1][z]
        sum += grid[x][y][z-1] + grid[x][y][z+1]
        return sum - 6 * center
    }

    // MARK: - Algorithm 4: Random L-System

    private func generateRandomLSystem(complexity: Double, density: Double, seed: Int) -> MeshData {
        var mesh = MeshData()

        // Random L-system rules
        let angle = Float(20 + drand48() * 40) * .pi / 180
        let lengthDecay = Float(0.6 + drand48() * 0.2)
        let radiusDecay = Float(0.6 + drand48() * 0.2)
        let branchCount = Int(2 + drand48() * 2)
        let iterations = Int(3 + complexity * 2)

        let startRadius = Float(0.06 * density + 0.02)
        let startLength = Float(0.3 + density * 0.2)

        // Recursive branching
        func branch(pos: SCNVector3, dir: SCNVector3, length: Float, radius: Float, depth: Int) {
            guard depth < iterations && radius > 0.005 else { return }

            let endPos = SCNVector3(
                pos.x + dir.x * length,
                pos.y + dir.y * length,
                pos.z + dir.z * length
            )

            addCylinder(to: &mesh, from: pos, to: endPos, radius: radius)

            // Create branches
            for i in 0..<branchCount {
                let branchAngle = angle * Float(1 + drand48() * 0.5 - 0.25)
                let rotAngle = Float(i) * 2 * .pi / Float(branchCount) + Float(drand48() * 0.5)

                let newDir = rotateVector(dir, around: perpendicular(to: dir), by: branchAngle)
                let finalDir = rotateVector(newDir, around: dir, by: rotAngle)

                branch(
                    pos: endPos,
                    dir: finalDir,
                    length: length * lengthDecay,
                    radius: radius * radiusDecay,
                    depth: depth + 1
                )
            }
        }

        // Start multiple trunks
        let numTrunks = Int(1 + density * 2)
        for t in 0..<numTrunks {
            let offsetX = Float(t - numTrunks / 2) * 0.3
            let startPos = SCNVector3(offsetX, -0.4, 0)
            let startDir = SCNVector3(Float(drand48() * 0.2 - 0.1), 1, Float(drand48() * 0.2 - 0.1))
            branch(pos: startPos, dir: normalize(startDir), length: startLength, radius: startRadius, depth: 0)
        }

        return mesh
    }

    // MARK: - Algorithm 5: Voronoi Mutation

    private func generateVoronoiMutation(complexity: Double, density: Double, seed: Int) -> MeshData {
        var mesh = MeshData()

        let numPoints = Int(8 + complexity * 15)
        let scale = Float(0.8)

        // Generate random seed points with mutations
        var points: [SCNVector3] = []
        for _ in 0..<numPoints {
            let x = Float(drand48() * 2 - 1) * scale
            let y = Float(drand48() * 2 - 1) * scale
            let z = Float(drand48() * 2 - 1) * scale
            points.append(SCNVector3(x, y, z))
        }

        // Create mutated cells around each point
        for point in points {
            let cellRadius = Float(0.08 + drand48() * 0.08) * Float(density + 0.5)
            let cellHeight = Float(0.1 + drand48() * 0.1) * Float(density + 0.5)
            let sides = Int(4 + drand48() * 5)
            let mutation = Float(0.3 + drand48() * 0.4) // How mutated the shape is

            addMutatedCell(to: &mesh, center: point, radius: cellRadius, height: cellHeight, sides: sides, mutation: mutation)
        }

        // Add connecting struts between nearby cells
        let connectionThreshold = Float(0.4 + density * 0.3)
        for i in 0..<points.count {
            for j in (i + 1)..<points.count {
                let dist = distance(points[i], points[j])
                if dist < connectionThreshold && drand48() > 0.3 {
                    let strutRadius = Float(0.01 + drand48() * 0.02)
                    addCylinder(to: &mesh, from: points[i], to: points[j], radius: strutRadius)
                }
            }
        }

        return mesh
    }

    private func addMutatedCell(to mesh: inout MeshData, center: SCNVector3, radius: Float, height: Float, sides: Int, mutation: Float) {
        var topPoints: [SCNVector3] = []
        var bottomPoints: [SCNVector3] = []

        for i in 0..<sides {
            let angle = Float(i) * 2 * .pi / Float(sides)
            let mutatedRadius = radius * (1 + Float(drand48() - 0.5) * mutation)
            let mutatedAngle = angle + Float(drand48() - 0.5) * mutation * 0.5

            let x = center.x + mutatedRadius * cos(mutatedAngle)
            let z = center.z + mutatedRadius * sin(mutatedAngle)

            let topY = center.y + height / 2 * (1 + Float(drand48() - 0.5) * mutation * 0.5)
            let bottomY = center.y - height / 2 * (1 + Float(drand48() - 0.5) * mutation * 0.5)

            topPoints.append(SCNVector3(x, topY, z))
            bottomPoints.append(SCNVector3(x, bottomY, z))
        }

        // Create faces
        for i in 0..<sides {
            let next = (i + 1) % sides

            // Top face
            mesh.addTriangle(
                SCNVector3(center.x, center.y + height / 2, center.z),
                topPoints[i],
                topPoints[next]
            )

            // Bottom face
            mesh.addTriangle(
                SCNVector3(center.x, center.y - height / 2, center.z),
                bottomPoints[next],
                bottomPoints[i]
            )

            // Side faces
            mesh.addTriangle(bottomPoints[i], bottomPoints[next], topPoints[i])
            mesh.addTriangle(bottomPoints[next], topPoints[next], topPoints[i])
        }
    }

    // MARK: - Helper Functions

    private func addCubeAt(to mesh: inout MeshData, x: Float, y: Float, z: Float, size: Float) {
        let s = size / 2

        let vertices = [
            SCNVector3(x - s, y - s, z - s), SCNVector3(x + s, y - s, z - s),
            SCNVector3(x + s, y + s, z - s), SCNVector3(x - s, y + s, z - s),
            SCNVector3(x - s, y - s, z + s), SCNVector3(x + s, y - s, z + s),
            SCNVector3(x + s, y + s, z + s), SCNVector3(x - s, y + s, z + s)
        ]

        // Front
        mesh.addTriangle(vertices[0], vertices[1], vertices[2])
        mesh.addTriangle(vertices[0], vertices[2], vertices[3])
        // Back
        mesh.addTriangle(vertices[5], vertices[4], vertices[7])
        mesh.addTriangle(vertices[5], vertices[7], vertices[6])
        // Top
        mesh.addTriangle(vertices[3], vertices[2], vertices[6])
        mesh.addTriangle(vertices[3], vertices[6], vertices[7])
        // Bottom
        mesh.addTriangle(vertices[4], vertices[5], vertices[1])
        mesh.addTriangle(vertices[4], vertices[1], vertices[0])
        // Left
        mesh.addTriangle(vertices[4], vertices[0], vertices[3])
        mesh.addTriangle(vertices[4], vertices[3], vertices[7])
        // Right
        mesh.addTriangle(vertices[1], vertices[5], vertices[6])
        mesh.addTriangle(vertices[1], vertices[6], vertices[2])
    }

    private func addCylinder(to mesh: inout MeshData, from start: SCNVector3, to end: SCNVector3, radius: Float) {
        let segments = 6
        let direction = normalize(SCNVector3(end.x - start.x, end.y - start.y, end.z - start.z))

        var perp1 = cross(direction, SCNVector3(0, 1, 0))
        if length(perp1) < 0.001 {
            perp1 = cross(direction, SCNVector3(1, 0, 0))
        }
        perp1 = normalize(perp1)
        let perp2 = cross(direction, perp1)

        var startPoints: [SCNVector3] = []
        var endPoints: [SCNVector3] = []

        for i in 0..<segments {
            let angle = Float(i) * 2 * .pi / Float(segments)
            let offset = SCNVector3(
                (perp1.x * cos(angle) + perp2.x * sin(angle)) * radius,
                (perp1.y * cos(angle) + perp2.y * sin(angle)) * radius,
                (perp1.z * cos(angle) + perp2.z * sin(angle)) * radius
            )

            startPoints.append(SCNVector3(start.x + offset.x, start.y + offset.y, start.z + offset.z))
            endPoints.append(SCNVector3(end.x + offset.x, end.y + offset.y, end.z + offset.z))
        }

        for i in 0..<segments {
            let next = (i + 1) % segments
            mesh.addTriangle(startPoints[i], startPoints[next], endPoints[i])
            mesh.addTriangle(startPoints[next], endPoints[next], endPoints[i])
            mesh.addTriangle(start, startPoints[next], startPoints[i])
            mesh.addTriangle(end, endPoints[i], endPoints[next])
        }
    }

    private func normalize(_ v: SCNVector3) -> SCNVector3 {
        let len = sqrt(v.x * v.x + v.y * v.y + v.z * v.z)
        guard len > 0 else { return v }
        return SCNVector3(v.x / len, v.y / len, v.z / len)
    }

    private func cross(_ a: SCNVector3, _ b: SCNVector3) -> SCNVector3 {
        SCNVector3(
            a.y * b.z - a.z * b.y,
            a.z * b.x - a.x * b.z,
            a.x * b.y - a.y * b.x
        )
    }

    private func length(_ v: SCNVector3) -> Float {
        sqrt(v.x * v.x + v.y * v.y + v.z * v.z)
    }

    private func distance(_ a: SCNVector3, _ b: SCNVector3) -> Float {
        let dx = b.x - a.x
        let dy = b.y - a.y
        let dz = b.z - a.z
        return sqrt(dx * dx + dy * dy + dz * dz)
    }

    private func perpendicular(to v: SCNVector3) -> SCNVector3 {
        if abs(v.x) < abs(v.y) {
            return normalize(cross(v, SCNVector3(1, 0, 0)))
        } else {
            return normalize(cross(v, SCNVector3(0, 1, 0)))
        }
    }

    private func rotateVector(_ v: SCNVector3, around axis: SCNVector3, by angle: Float) -> SCNVector3 {
        let c = cos(angle)
        let s = sin(angle)
        let t = 1 - c

        let x = v.x * (t * axis.x * axis.x + c) + v.y * (t * axis.x * axis.y - s * axis.z) + v.z * (t * axis.x * axis.z + s * axis.y)
        let y = v.x * (t * axis.x * axis.y + s * axis.z) + v.y * (t * axis.y * axis.y + c) + v.z * (t * axis.y * axis.z - s * axis.x)
        let z = v.x * (t * axis.x * axis.z - s * axis.y) + v.y * (t * axis.y * axis.z + s * axis.x) + v.z * (t * axis.z * axis.z + c)

        return SCNVector3(x, y, z)
    }

    // MARK: - Property Calculation

    private func calculateProperties(mesh: MeshData) -> StructuralProperties {
        var totalSurfaceArea: Float = 0
        var minBound = SCNVector3(Float.greatestFiniteMagnitude, Float.greatestFiniteMagnitude, Float.greatestFiniteMagnitude)
        var maxBound = SCNVector3(-Float.greatestFiniteMagnitude, -Float.greatestFiniteMagnitude, -Float.greatestFiniteMagnitude)

        // Calculate surface area and bounds
        let triangleCount = mesh.indices.count / 3
        for i in 0..<triangleCount {
            let idx0 = Int(mesh.indices[i * 3])
            let idx1 = Int(mesh.indices[i * 3 + 1])
            let idx2 = Int(mesh.indices[i * 3 + 2])

            guard idx0 < mesh.vertices.count, idx1 < mesh.vertices.count, idx2 < mesh.vertices.count else { continue }

            let v0 = mesh.vertices[idx0]
            let v1 = mesh.vertices[idx1]
            let v2 = mesh.vertices[idx2]

            // Update bounds
            for v in [v0, v1, v2] {
                minBound.x = min(minBound.x, v.x)
                minBound.y = min(minBound.y, v.y)
                minBound.z = min(minBound.z, v.z)
                maxBound.x = max(maxBound.x, v.x)
                maxBound.y = max(maxBound.y, v.y)
                maxBound.z = max(maxBound.z, v.z)
            }

            // Triangle area
            let edge1 = SCNVector3(v1.x - v0.x, v1.y - v0.y, v1.z - v0.z)
            let edge2 = SCNVector3(v2.x - v0.x, v2.y - v0.y, v2.z - v0.z)
            let crossProduct = cross(edge1, edge2)
            totalSurfaceArea += length(crossProduct) / 2
        }

        // Bounding box volume
        let boundingVolume = (maxBound.x - minBound.x) * (maxBound.y - minBound.y) * (maxBound.z - minBound.z)

        // Estimate porosity (ratio of empty space)
        let estimatedSolidVolume = totalSurfaceArea * 0.01 // Rough estimate
        let porosity = max(0, min(1, 1 - (estimatedSolidVolume / max(boundingVolume, 0.001))))

        // Surface area to volume ratio
        let surfaceToVolume = totalSurfaceArea / max(boundingVolume, 0.001)

        // Complexity (based on triangle count)
        let complexity = min(1.0, Double(triangleCount) / 10000.0)

        // Symmetry detection (simplified)
        let symmetry = detectSymmetry(mesh: mesh)

        return StructuralProperties(
            surfaceArea: Double(totalSurfaceArea),
            boundingVolume: Double(boundingVolume),
            surfaceToVolumeRatio: Double(surfaceToVolume),
            porosity: Double(porosity),
            complexity: complexity,
            symmetryType: symmetry,
            triangleCount: triangleCount,
            vertexCount: mesh.vertices.count
        )
    }

    private func detectSymmetry(mesh: MeshData) -> String {
        // Simplified symmetry detection based on vertex distribution
        var xSymmetry: Float = 0
        var ySymmetry: Float = 0
        var zSymmetry: Float = 0

        for v in mesh.vertices {
            xSymmetry += abs(v.x)
            ySymmetry += abs(v.y)
            zSymmetry += abs(v.z)
        }

        let total = xSymmetry + ySymmetry + zSymmetry
        guard total > 0 else { return "None" }

        let xRatio = xSymmetry / total
        let yRatio = ySymmetry / total
        let zRatio = zSymmetry / total

        let variance = abs(xRatio - 0.333) + abs(yRatio - 0.333) + abs(zRatio - 0.333)

        if variance < 0.1 {
            return "Roughly Symmetric"
        } else if yRatio > 0.4 {
            return "Vertical Bias"
        } else if xRatio > 0.4 || zRatio > 0.4 {
            return "Horizontal Bias"
        } else {
            return "Asymmetric"
        }
    }
}
