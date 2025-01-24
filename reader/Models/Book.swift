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
    
    init(
        title: String,
        author: String? = nil,
        filePath: String,
        fileType: BookType,
        encoding: String.Encoding = .utf8,
        lastReadChapter: Int = 0,
        lastReadPosition: Double = 0,
        sourceUrl: String? = nil,
        groupName: String? = nil,
        lastReadTime: Date? = nil,
        isLocal: Bool = false,
        localPath: String? = nil,
        isFavorite: Bool = false,
        isReading: Bool = false,
        coverUrl: String? = nil
    ) {
        self.title = title
        self.author = author
        self.filePath = filePath
        self.fileType = fileType
        self.encodingRawValue = encoding.rawValue
        self.lastReadChapter = lastReadChapter
        self.lastReadPosition = lastReadPosition
        self.createTime = Date()
        self.updateTime = Date()
        self.sourceUrl = sourceUrl
        self.groupName = groupName
        self.lastReadTime = lastReadTime
        self.isLocal = isLocal
        self.localPath = localPath
        self.isFavorite = isFavorite
        self.isReading = isReading
        self.coverUrl = coverUrl
    }
}

enum BookType: String, Codable {
    case txt
    case epub
    // 后续可扩展其他格式
}