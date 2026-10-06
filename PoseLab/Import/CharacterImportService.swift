import Foundation

final class CharacterImportService {
    struct ImportedCharacter {
        let displayName: String
        let sourceURL: URL
        let jointNames: [String]
    }

    enum ImportError: Error {
        case unsupportedFormat
        case missingSkeleton
    }
}
