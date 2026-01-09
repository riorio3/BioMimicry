import Foundation

class StorageService: ObservableObject {
    static let shared = StorageService()

    @Published var savedDesigns: [GeneratedDesign] = []

    private let designsKey = "saved_designs"

    private init() {
        loadDesigns()
    }

    func save(_ design: GeneratedDesign) {
        savedDesigns.insert(design, at: 0)
        persistDesigns()
    }

    func delete(_ design: GeneratedDesign) {
        savedDesigns.removeAll { $0.id == design.id }
        persistDesigns()
    }

    func deleteAll() {
        savedDesigns.removeAll()
        persistDesigns()
    }

    private func loadDesigns() {
        guard let data = UserDefaults.standard.data(forKey: designsKey),
              let designs = try? JSONDecoder().decode([GeneratedDesign].self, from: data) else {
            return
        }
        savedDesigns = designs
    }

    private func persistDesigns() {
        guard let data = try? JSONEncoder().encode(savedDesigns) else { return }
        UserDefaults.standard.set(data, forKey: designsKey)
    }
}
