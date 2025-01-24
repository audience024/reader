import Foundation

protocol BookParserProtocol {
    func parseChapters(for book: Book) async throws -> [Chapter]
    func loadChapterContent(_ chapter: Chapter) async throws -> String
}

enum BookParserError: Error {
    case fileNotFound
    case invalidEncoding
    case parseError(String)
    case readError(String)
} 