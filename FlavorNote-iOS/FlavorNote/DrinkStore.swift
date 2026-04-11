import Foundation

struct DrinkRecord: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var sweet: Double
    var rich: Double
    var tags: [String]
    var type: DrinkType
    var isFavorite: Bool
    var createdAt: Date
    var imageData: Data?
    var voiceNote: String?
}

enum DrinkType: String, CaseIterable, Codable, Identifiable {
    case milkTea = "Milk Tea"
    case coffee = "Coffee"
    case tea = "Tea"
    case juice = "Juice"
    case other = "Other"

    var id: String { rawValue }
}

final class DrinkStore: ObservableObject {
    @Published var records: [DrinkRecord] = [] {
        didSet { save() }
    }

    private let storageKey = "flavornote.records"

    init() {
        load()
    }

    var averageSweet: Int {
        guard !records.isEmpty else { return 70 }
        return Int(records.map(\.sweet).reduce(0, +) / Double(records.count))
    }

    var averageRich: Int {
        guard !records.isEmpty else { return 60 }
        return Int(records.map(\.rich).reduce(0, +) / Double(records.count))
    }

    var commonType: DrinkType {
        let grouped = Dictionary(grouping: records, by: \.type)
        return grouped.max { $0.value.count < $1.value.count }?.key ?? .milkTea
    }

    var favorites: [DrinkRecord] {
        records.filter(\.isFavorite)
    }

    var typeDistribution: [(DrinkType, Double)] {
        guard !records.isEmpty else {
            return [(.milkTea, 0.45), (.coffee, 0.35), (.tea, 0.20)]
        }

        let grouped = Dictionary(grouping: records, by: \.type)
        return DrinkType.allCases.compactMap { type in
            guard let count = grouped[type]?.count, count > 0 else { return nil }
            return (type, Double(count) / Double(records.count))
        }
    }

    func add(_ record: DrinkRecord) {
        records.insert(record, at: 0)
    }

    func toggleFavorite(_ record: DrinkRecord) {
        guard let index = records.firstIndex(where: { $0.id == record.id }) else { return }
        records[index].isFavorite.toggle()
    }

    private func load() {
        guard
            let data = UserDefaults.standard.data(forKey: storageKey),
            let decoded = try? JSONDecoder().decode([DrinkRecord].self, from: data)
        else {
            records = Self.seed
            return
        }
        records = decoded
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(records) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    private static let seed: [DrinkRecord] = [
        DrinkRecord(name: "Iced Latte", sweet: 58, rich: 72, tags: ["Creamy", "Iced"], type: .coffee, isFavorite: true, createdAt: Date().addingTimeInterval(-7200)),
        DrinkRecord(name: "Milk Tea", sweet: 78, rich: 66, tags: ["Creamy", "Strong"], type: .milkTea, isFavorite: true, createdAt: Date().addingTimeInterval(-86400)),
        DrinkRecord(name: "Fruit Tea", sweet: 64, rich: 28, tags: ["Fresh", "Fruity"], type: .tea, isFavorite: false, createdAt: Date().addingTimeInterval(-172800))
    ]
}
