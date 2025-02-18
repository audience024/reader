import Foundation
import SwiftData
import SwiftUI

@Model
final class Book {
    var title: String
    var author: String?
    var filePath: String
    var fileType: BookType
    var encodingRawValue: UInt  // 存储 String.Encoding 的原始值
    var lastReadChapter: Int
    var lastReadPosition: Double
    var createTime: Date
    var updateTime: Date
    var sourceUrl: String?
    var groupName: String?
    var lastReadTime: Date?
    var isLocal: Bool
    var localPath: String?
    var isFavorite: Bool
    var isReading: Bool
    var coverUrl: String?
    
    @Relationship(deleteRule: .cascade, inverse: \Chapter.book)
    var chapters: [Chapter] = []
    
    // 计算属性，用于转换 encoding
    var encoding: String.Encoding {
        get { String.Encoding(rawValue: encodingRawValue) }
        set { encodingRawValue = newValue.rawValue }
    }
    
    init(title: String, filePath: String, fileType: BookType) {
        self.title = title
        self.author = nil
        self.filePath = filePath
        self.fileType = fileType
        self.encodingRawValue = String.Encoding.utf8.rawValue
        self.lastReadChapter = 0
        self.lastReadPosition = 0
        self.createTime = Date()
        self.updateTime = Date()
        self.isLocal = true
        self.isFavorite = false
        self.isReading = false
    }
}

enum BookType: String, Codable {
    case txt
    case epub
    // 后续可扩展其他格式
}