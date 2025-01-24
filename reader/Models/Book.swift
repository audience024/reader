import Foundation
import SwiftData

@Model
final class Book {
    var title: String
    var author: String
    var coverUrl: String?
    var lastChapter: String?
    var latestChapter: String?
    var sourceUrl: String
    var groupName: String?
    var lastReadTime: Date?
    var isLocal: Bool
    var localPath: String?
    var isFavorite: Bool
    var isReading: Bool
    
    init(title: String, author: String, sourceUrl: String) {
        self.isFavorite = false
        self.isReading = false
        self.title = title
        self.author = author
        self.sourceUrl = sourceUrl
        self.isLocal = false
    }
}