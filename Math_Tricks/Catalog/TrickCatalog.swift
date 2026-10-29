import Foundation

nonisolated struct CatalogTrick: Codable, Sendable, Identifiable {
    let id: Int
    let key: String
    let groupID: Int
    let order: String
    let nameKey: String
    let ruleKey: String
    let formulaKey: String
    let initiallyUnlocked: Bool
}
nonisolated struct CatalogGroup: Codable, Sendable, Identifiable {
    let id: Int
    let nameKey: String
    let iconName: String
}

nonisolated struct TrainingCatalogProgress: Sendable {
    let tricks: [TrickProgress]
    let completedLevels: [Int: Int]
    var completedTotal: Int { completedLevels.values.reduce(0, +) }
}
nonisolated struct TrickCatalog: Codable, Sendable {
    let tricks: [CatalogTrick]
    let groups: [CatalogGroup]
    let unlockPrice: Int64
    let levelCount: Int
    static let shared: TrickCatalog = {
        guard let url = Bundle.main.url(forResource: "TrickCatalog", withExtension: "json"),
              let bytes = try? Data(contentsOf: url),
              let catalog = try? JSONDecoder().decode(TrickCatalog.self, from: bytes),
              catalog.tricks.count == 107, Set(catalog.tricks.map(\.id)).count == 107 else {
            preconditionFailure("Bundled Android trick catalog is missing or invalid")
        }
        return catalog
    }()
    func trick(_ id: Int) -> CatalogTrick? { tricks.first { $0.id == id } }
    func tricks(in group: Int) -> [CatalogTrick] { tricks.filter { $0.groupID == group }.sorted { $0.order < $1.order } }
}

nonisolated enum CatalogText {
    static func text(_ key: String) -> String { NSLocalizedString(key, tableName: "Catalog", value: key, comment: "") }
    static func ui(_ key: String) -> String { NSLocalizedString(key, tableName: "Interface", value: key, comment: "") }
}
