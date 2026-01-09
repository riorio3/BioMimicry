import Foundation
import SwiftUI

@MainActor
class GalleryViewModel: ObservableObject {
    @Published var designs: [GeneratedDesign] = []
    @Published var selectedDesign: GeneratedDesign?

    private let storage = StorageService.shared

    init() {
        loadDesigns()
    }

    func loadDesigns() {
        designs = storage.savedDesigns
    }

    func selectDesign(_ design: GeneratedDesign) {
        selectedDesign = design
    }

    func deleteDesign(_ design: GeneratedDesign) {
        storage.delete(design)
        loadDesigns()
    }

    func deleteAll() {
        storage.deleteAll()
        loadDesigns()
    }
}
