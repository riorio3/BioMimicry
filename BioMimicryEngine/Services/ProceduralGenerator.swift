import Foundation
import SceneKit

class ProceduralGenerator {
    static let shared = ProceduralGenerator()

    private init() {}

    func generateGeometry(for design: GeneratedDesign) -> SCNGeometry {
        let mesh = generateMesh(for: design)
        return createGeometry(from: mesh)
    }

    func generateMesh(for design: GeneratedDesign) -> MeshData {
        switch design.pattern.type {
        case .honeycomb:
            return generateHoneycomb(params: design.parameters)
        case .voronoi:
            return generateVoronoi(params: design.parameters)
        case .branching:
            return generateBranching(params: design.parameters)
        case .spiral:
            return generateSpiral(params: design.parameters)
        case .gyroid:
            return generateGyroid(params: design.parameters)
        }
    }

    // MARK: - Honeycomb Generation
    private func generateHoneycomb(params: GeneratedDesign.GenerationParameters) -> MeshData {
        var mesh = MeshData()
        let hexRadius: Float = 0.15 * Float(params.scale)
        let hexHeight: Float = 0.3 * Float(params.scale)
        let gridSize = Int(5 * params.density) + 2

        for row in -gridSize...gridSize {
            for col in -gridSize...gridSize {
                let xOffset = Float(col) * hexRadius * 1.75
                let yOffset = Float(row) * hexRadius * 1.5 + (col % 2 == 0 ? 0 : hexRadius * 0.75)

                if sqrt(xOffset * xOffset + yOffset * yOffset) < Float(gridSize) * hexRadius {
                    addHexagonalPrism(to: &mesh, center: SCNVector3(xOffset, 0, yOffset), radius: hexRadius * 0.9, height: hexHeight)
                }
            }
        }

        return mesh
    }

    private func addHexagonalPrism(to mesh: inout MeshData, center: SCNVector3, radius: Float, height: Float) {
        var hexPoints: [SCNVector3] = []
        for i in 0..<6 {
            let angle = Float(i) * .pi / 3.0
            let x = center.x + radius * cos(angle)
            let z = center.z + radius * sin(angle)
            hexPoints.append(SCNVector3(x, center.y, z))
        }

        // Top and bottom faces
        let topY = center.y + height / 2
        let bottomY = center.y - height / 2

        for i in 0..<6 {
            let next = (i + 1) % 6

            // Top face triangles
            mesh.addTriangle(
                SCNVector3(center.x, topY, center.z),
                SCNVector3(hexPoints[i].x, topY, hexPoints[i].z),
                SCNVector3(hexPoints[next].x, topY, hexPoints[next].z)
            )

            // Bottom face triangles
            mesh.addTriangle(
                SCNVector3(center.x, bottomY, center.z),
                SCNVector3(hexPoints[next].x, bottomY, hexPoints[next].z),
                SCNVector3(hexPoints[i].x, bottomY, hexPoints[i].z)
            )

            // Side faces
            mesh.addTriangle(
                SCNVector3(hexPoints[i].x, bottomY, hexPoints[i].z),
                SCNVector3(hexPoints[next].x, bottomY, hexPoints[next].z),
                SCNVector3(hexPoints[i].x, topY, hexPoints[i].z)
            )
            mesh.addTriangle(
                SCNVector3(hexPoints[next].x, bottomY, hexPoints[next].z),
                SCNVector3(hexPoints[next].x, topY, hexPoints[next].z),
                SCNVector3(hexPoints[i].x, topY, hexPoints[i].z)
            )
        }
    }

    // MARK: - Voronoi Generation
    private func generateVoronoi(params: GeneratedDesign.GenerationParameters) -> MeshData {
        var mesh = MeshData()
        srand48(params.randomSeed)

        let numPoints = Int(15 * params.density) + 5
        var points: [SCNVector3] = []

        // Generate random seed points
        for _ in 0..<numPoints {
            let x = Float(drand48() * 2 - 1) * Float(params.scale)
            let z = Float(drand48() * 2 - 1) * Float(params.scale)
            points.append(SCNVector3(x, 0, z))
        }

        // Create cell structures around each point
        let cellRadius: Float = 0.15 * Float(params.scale)
        let cellHeight: Float = 0.2 * Float(params.scale)

        for point in points {
            addVoronoiCell(to: &mesh, center: point, radius: cellRadius, height: cellHeight, seed: params.randomSeed)
        }

        return mesh
    }

    private func addVoronoiCell(to mesh: inout MeshData, center: SCNVector3, radius: Float, height: Float, seed: Int) {
        let sides = Int.random(in: 5...8)
        var cellPoints: [SCNVector3] = []

        for i in 0..<sides {
            let angle = Float(i) * 2 * .pi / Float(sides) + Float.random(in: -0.2...0.2)
            let r = radius * Float.random(in: 0.7...1.0)
            let x = center.x + r * cos(angle)
            let z = center.z + r * sin(angle)
            cellPoints.append(SCNVector3(x, center.y, z))
        }

        let topY = center.y + height / 2
        let bottomY = center.y - height / 2

        for i in 0..<sides {
            let next = (i + 1) % sides

            // Top face
            mesh.addTriangle(
                SCNVector3(center.x, topY, center.z),
                SCNVector3(cellPoints[i].x, topY, cellPoints[i].z),
                SCNVector3(cellPoints[next].x, topY, cellPoints[next].z)
            )

            // Bottom face
            mesh.addTriangle(
                SCNVector3(center.x, bottomY, center.z),
                SCNVector3(cellPoints[next].x, bottomY, cellPoints[next].z),
                SCNVector3(cellPoints[i].x, bottomY, cellPoints[i].z)
            )

            // Side faces
            mesh.addTriangle(
                SCNVector3(cellPoints[i].x, bottomY, cellPoints[i].z),
                SCNVector3(cellPoints[next].x, bottomY, cellPoints[next].z),
                SCNVector3(cellPoints[i].x, topY, cellPoints[i].z)
            )
            mesh.addTriangle(
                SCNVector3(cellPoints[next].x, bottomY, cellPoints[next].z),
                SCNVector3(cellPoints[next].x, topY, cellPoints[next].z),
                SCNVector3(cellPoints[i].x, topY, cellPoints[i].z)
            )
        }
    }

    // MARK: - Branching Generation
    private func generateBranching(params: GeneratedDesign.GenerationParameters) -> MeshData {
        var mesh = MeshData()
        srand48(params.randomSeed)

        let iterations = min(params.iterations + 2, 5)
        let scale = Float(params.scale)

        // Start with trunk
        generateBranch(
            to: &mesh,
            start: SCNVector3(0, -0.5 * scale, 0),
            end: SCNVector3(0, 0.2 * scale, 0),
            radius: 0.08 * scale,
            depth: 0,
            maxDepth: iterations
        )

        return mesh
    }

    private func generateBranch(to mesh: inout MeshData, start: SCNVector3, end: SCNVector3, radius: Float, depth: Int, maxDepth: Int) {
        addCylinder(to: &mesh, from: start, to: end, radius: radius)

        guard depth < maxDepth else { return }

        let numBranches = depth == 0 ? 3 : 2
        let branchLength = length(from: start, to: end) * 0.7

        for i in 0..<numBranches {
            let angleOffset = Float(i) * 2 * .pi / Float(numBranches) + Float.random(in: -0.3...0.3)
            let spreadAngle = Float.random(in: 0.4...0.8)

            let direction = normalize(SCNVector3(
                sin(spreadAngle) * cos(angleOffset),
                cos(spreadAngle),
                sin(spreadAngle) * sin(angleOffset)
            ))

            let newEnd = SCNVector3(
                end.x + direction.x * branchLength,
                end.y + direction.y * branchLength,
                end.z + direction.z * branchLength
            )

            generateBranch(
                to: &mesh,
                start: end,
                end: newEnd,
                radius: radius * 0.65,
                depth: depth + 1,
                maxDepth: maxDepth
            )
        }
    }

    private func addCylinder(to mesh: inout MeshData, from start: SCNVector3, to end: SCNVector3, radius: Float) {
        let segments = 6
        let direction = normalize(SCNVector3(end.x - start.x, end.y - start.y, end.z - start.z))

        // Find perpendicular vectors
        var perp1 = cross(direction, SCNVector3(0, 1, 0))
        if length(from: .init(), to: perp1) < 0.001 {
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

            // Side faces
            mesh.addTriangle(startPoints[i], startPoints[next], endPoints[i])
            mesh.addTriangle(startPoints[next], endPoints[next], endPoints[i])

            // End caps
            mesh.addTriangle(start, startPoints[next], startPoints[i])
            mesh.addTriangle(end, endPoints[i], endPoints[next])
        }
    }

    // MARK: - Spiral Generation
    private func generateSpiral(params: GeneratedDesign.GenerationParameters) -> MeshData {
        var mesh = MeshData()
        let scale = Float(params.scale)
        let turns = 3.0 + params.density * 2
        let segments = Int(turns * 20)

        var prevPoints: [SCNVector3]?
        let tubeRadius: Float = 0.03 * scale

        for i in 0...segments {
            let t = Float(i) / Float(segments)
            let angle = Float(turns) * 2 * .pi * t
            let spiralRadius = 0.1 * scale + t * 0.5 * scale

            let centerX = spiralRadius * cos(angle)
            let centerY = t * 0.8 * scale - 0.4 * scale
            let centerZ = spiralRadius * sin(angle)

            // Create tube cross-section
            var currentPoints: [SCNVector3] = []
            let tubeSides = 6

            let tangent = normalize(SCNVector3(
                -spiralRadius * sin(angle) + 0.5 * scale * cos(angle) / Float(turns),
                0.8 * scale / Float(segments),
                spiralRadius * cos(angle) + 0.5 * scale * sin(angle) / Float(turns)
            ))

            var perp1 = cross(tangent, SCNVector3(0, 1, 0))
            if length(from: .init(), to: perp1) < 0.001 {
                perp1 = cross(tangent, SCNVector3(1, 0, 0))
            }
            perp1 = normalize(perp1)
            let perp2 = cross(tangent, perp1)

            for j in 0..<tubeSides {
                let tubeAngle = Float(j) * 2 * .pi / Float(tubeSides)
                let offset = SCNVector3(
                    (perp1.x * cos(tubeAngle) + perp2.x * sin(tubeAngle)) * tubeRadius,
                    (perp1.y * cos(tubeAngle) + perp2.y * sin(tubeAngle)) * tubeRadius,
                    (perp1.z * cos(tubeAngle) + perp2.z * sin(tubeAngle)) * tubeRadius
                )
                currentPoints.append(SCNVector3(centerX + offset.x, centerY + offset.y, centerZ + offset.z))
            }

            if let prev = prevPoints {
                for j in 0..<tubeSides {
                    let next = (j + 1) % tubeSides
                    mesh.addTriangle(prev[j], prev[next], currentPoints[j])
                    mesh.addTriangle(prev[next], currentPoints[next], currentPoints[j])
                }
            }

            prevPoints = currentPoints
        }

        return mesh
    }

    // MARK: - Gyroid Generation
    private func generateGyroid(params: GeneratedDesign.GenerationParameters) -> MeshData {
        var mesh = MeshData()
        let scale = Float(params.scale)
        let resolution = Int(10 * params.density) + 8
        let size = scale * 1.0
        let step = size / Float(resolution)
        let frequency: Float = 4.0

        // Marching cubes approximation for gyroid surface
        for xi in 0..<resolution {
            for yi in 0..<resolution {
                for zi in 0..<resolution {
                    let x = Float(xi) * step - size / 2
                    let y = Float(yi) * step - size / 2
                    let z = Float(zi) * step - size / 2

                    // Sample gyroid function at cube corners
                    let corners = [
                        gyroidValue(x, y, z, frequency),
                        gyroidValue(x + step, y, z, frequency),
                        gyroidValue(x + step, y + step, z, frequency),
                        gyroidValue(x, y + step, z, frequency),
                        gyroidValue(x, y, z + step, frequency),
                        gyroidValue(x + step, y, z + step, frequency),
                        gyroidValue(x + step, y + step, z + step, frequency),
                        gyroidValue(x, y + step, z + step, frequency)
                    ]

                    // Simple surface extraction - add triangles where sign changes
                    addGyroidTriangles(to: &mesh, x: x, y: y, z: z, step: step, corners: corners)
                }
            }
        }

        return mesh
    }

    private func gyroidValue(_ x: Float, _ y: Float, _ z: Float, _ freq: Float) -> Float {
        sin(freq * x) * cos(freq * y) + sin(freq * y) * cos(freq * z) + sin(freq * z) * cos(freq * x)
    }

    private func addGyroidTriangles(to mesh: inout MeshData, x: Float, y: Float, z: Float, step: Float, corners: [Float]) {
        let threshold: Float = 0.0

        // Check if surface crosses this cell
        var hasPositive = false
        var hasNegative = false
        for c in corners {
            if c > threshold { hasPositive = true }
            if c < threshold { hasNegative = true }
        }

        guard hasPositive && hasNegative else { return }

        // Simplified surface - place triangles at cell center
        let cx = x + step / 2
        let cy = y + step / 2
        let cz = z + step / 2
        let s = step * 0.4

        // Add small triangulated surface patch
        mesh.addTriangle(
            SCNVector3(cx - s, cy, cz - s),
            SCNVector3(cx + s, cy, cz - s),
            SCNVector3(cx, cy + s, cz + s)
        )
        mesh.addTriangle(
            SCNVector3(cx + s, cy, cz - s),
            SCNVector3(cx + s, cy, cz + s),
            SCNVector3(cx, cy + s, cz + s)
        )
    }

    // MARK: - Geometry Creation
    private func createGeometry(from mesh: MeshData) -> SCNGeometry {
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

        // Wireframe green material
        let material = SCNMaterial()
        material.diffuse.contents = UIColor(red: 0, green: 1, blue: 0.4, alpha: 1)
        material.emission.contents = UIColor(red: 0, green: 0.5, blue: 0.2, alpha: 1)
        material.fillMode = .lines
        material.isDoubleSided = true
        geometry.materials = [material]

        return geometry
    }

    // MARK: - Helper Functions
    private func length(from a: SCNVector3, to b: SCNVector3) -> Float {
        let dx = b.x - a.x
        let dy = b.y - a.y
        let dz = b.z - a.z
        return sqrt(dx * dx + dy * dy + dz * dz)
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
}
