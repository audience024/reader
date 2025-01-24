import Foundation

class TxtParser: BookParserProtocol {
    private let chapterPattern = "^第[0-9一二三四五六七八九十百千万]+[章节卷集部篇].*$"
    private let minChapterLength = 300  // 最小章节长度
    
    // 支持的编码列表
    private let supportedEncodings: [String.Encoding] = [
        .utf8,
        .init(rawValue: CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue))),
        .init(rawValue: CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.big5.rawValue))),
        .init(rawValue: CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_2312_80.rawValue))),
        .ascii,
        .unicode
    ]
    
    func parseBook(at path: String) async throws -> Book {
        guard FileManager.default.fileExists(atPath: path) else {
            throw BookParserError.fileNotFound
        }
        
        let url = URL(fileURLWithPath: path)
        let fileName = url.lastPathComponent
        
        return Book(
            title: fileName.replacingOccurrences(of: ".txt", with: ""),
            filePath: path,
            fileType: .txt
        )
    }
    
    func parseChapters(for book: Book) async throws -> [Chapter] {
        guard let data = FileManager.default.contents(atPath: book.filePath) else {
            throw BookParserError.fileNotFound
        }
        
        // 尝试使用书籍指定的编码
        if let content = String(data: data, encoding: book.encoding) {
            return try parseContent(content, for: book)
        }
        
        // 如果指定编码失败，尝试其他编码
        for encoding in supportedEncodings {
            if let content = String(data: data, encoding: encoding) {
                // 更新书籍的编码设置
                book.encoding = encoding
                return try parseContent(content, for: book)
            }
        }
        
        throw BookParserError.invalidEncoding
    }
    
    private func parseContent(_ content: String, for book: Book) throws -> [Chapter] {
        var chapters: [Chapter] = []
        let lines = content.components(separatedBy: .newlines)
        
        var currentChapterTitle = "第1章"
        var currentChapterStartOffset: Int64 = 0
        var currentOffset: Int64 = 0
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if isChapterTitle(trimmedLine) && currentOffset > currentChapterStartOffset {
                // 保存当前章节
                let chapter = Chapter(
                    title: currentChapterTitle,
                    startOffset: currentChapterStartOffset,
                    endOffset: currentOffset,
                    book: book
                )
                chapters.append(chapter)
                
                // 开始新章节
                currentChapterTitle = trimmedLine
                currentChapterStartOffset = currentOffset
            }
            currentOffset += Int64(line.count + 1) // +1 for newline
        }
        
        // 保存最后一章
        if currentOffset > currentChapterStartOffset {
            let chapter = Chapter(
                title: currentChapterTitle,
                startOffset: currentChapterStartOffset,
                endOffset: currentOffset,
                book: book
            )
            chapters.append(chapter)
        }
        
        // 如果没有检测到任何章节，创建一个包含全部内容的章节
        if chapters.isEmpty {
            let chapter = Chapter(
                title: "全文",
                startOffset: 0,
                endOffset: Int64(content.count),
                book: book
            )
            chapters.append(chapter)
        }
        
        return chapters
    }
    
    func loadChapterContent(_ chapter: Chapter) async throws -> String {
        guard let data = FileManager.default.contents(atPath: chapter.book.filePath) else {
            throw BookParserError.fileNotFound
        }
        
        guard let content = String(data: data, encoding: chapter.book.encoding) else {
            throw BookParserError.invalidEncoding
        }
        
        let start = content.index(content.startIndex, offsetBy: Int(chapter.startOffset))
        let end = content.index(content.startIndex, offsetBy: Int(chapter.endOffset))
        return String(content[start..<end])
    }
    
    private func isChapterTitle(_ line: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: chapterPattern, options: []) else {
            return false
        }
        let range = NSRange(location: 0, length: line.utf16.count)
        return regex.firstMatch(in: line, options: [], range: range) != nil
    }
} 