import Foundation

struct ClipboardItem: Identifiable, Codable, Equatable {
    enum Kind: String, Codable {
        case text
        case image
        case file
    }

    let id: UUID
    let kind: Kind
    var text: String?
    var imageData: Data?
    var filePaths: [String]
    var isFavorite: Bool
    let createdAt: Date

    init(
        id: UUID,
        kind: Kind,
        text: String? = nil,
        imageData: Data? = nil,
        filePaths: [String] = [],
        isFavorite: Bool = false,
        createdAt: Date
    ) {
        self.id = id
        self.kind = kind
        self.text = text
        self.imageData = imageData
        self.filePaths = filePaths
        self.isFavorite = isFavorite
        self.createdAt = createdAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        kind = try container.decode(Kind.self, forKey: .kind)
        text = try container.decodeIfPresent(String.self, forKey: .text)
        imageData = try container.decodeIfPresent(Data.self, forKey: .imageData)
        filePaths = try container.decodeIfPresent([String].self, forKey: .filePaths) ?? []
        isFavorite = try container.decodeIfPresent(Bool.self, forKey: .isFavorite) ?? false
        createdAt = try container.decode(Date.self, forKey: .createdAt)
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case kind
        case text
        case imageData
        case filePaths
        case isFavorite
        case createdAt
    }

    var title: String {
        switch kind {
        case .text:
            let raw = text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            return raw.isEmpty ? "Empty text" : raw.singleLinePreview(limit: 80)
        case .image:
            return "Image copied at \(createdAt.shortTimeString)"
        case .file:
            guard let firstPath = filePaths.first else { return "File" }
            let firstName = URL(fileURLWithPath: firstPath).lastPathComponent
            if filePaths.count == 1 {
                return firstName
            }
            return "\(firstName) and \(filePaths.count - 1) more"
        }
    }

    var menuTitle: String {
        title.singleLinePreview(limit: 30)
    }
}
