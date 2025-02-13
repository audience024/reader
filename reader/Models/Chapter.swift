import Foundation
import SwiftData

@Model
final class Chapter {
    var id: UUID
    var title: String
    var startOffset: Int64
    var endOffset: Int64
    var book: Book
    
    init(title: String, startOffset: Int64, endOffset: Int64, book: Book) {
        self.id = UUID()
        self.title = title
        self.startOffset = startOffset
        self.endOffset = endOffset
        self.book = book
    }
} 