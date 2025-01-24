import SwiftUI
import SwiftData

// 导入自定义模型和协议
@preconcurrency import class Foundation.NSObject

// 导入自定义类型
@preconcurrency import struct Foundation.URL
@preconcurrency import struct Foundation.Data
@preconcurrency import struct Foundation.Date

// 导入自定义模型
@preconcurrency import class Foundation.FileHandle
@preconcurrency import class Foundation.FileManager

@Observable
class ReaderViewModel {
    private var parser: any BookParserProtocol
    private var book: Book
    private var chapters: [Chapter] = []
    
    var currentChapter: Chapter?
    var currentPage: Int = 0
    var totalPages: Int = 0
    var pages: [String] = []
    
    var readingConfig: ReadingConfig
    
    init(book: Book, parser: any BookParserProtocol = TxtParser()) {
        self.book = book
        self.parser = parser
        self.readingConfig = ReadingConfig(
            fontSize: 18,
            lineSpacing: 8,
            paragraphSpacing: 12,
            backgroundColor: .white,
            textColor: .black
        )
    }
    
    func loadBook() async throws {
        chapters = try await parser.parseChapters(for: book)
        if let firstChapter = chapters.first {
            try await loadChapter(firstChapter)
        }
    }
    
    func loadChapter(_ chapter: Chapter) async throws {
        currentChapter = chapter
        let content = try await parser.loadChapterContent(chapter)
        pages = paginateContent(content)
        currentPage = 0
        totalPages = pages.count
    }
    
    func nextPage() -> Bool {
        guard currentPage < totalPages - 1 else {
            return false
        }
        currentPage += 1
        return true
    }
    
    func previousPage() -> Bool {
        guard currentPage > 0 else {
            return false
        }
        currentPage -= 1
        return true
    }
    
    private func paginateContent(_ content: String) -> [String] {
        var pages: [String] = []
        var currentPage = ""
        var currentCharCount = 0
        
        let paragraphs = content.components(separatedBy: .newlines)
        
        for paragraph in paragraphs {
            let trimmedParagraph = paragraph.trimmingCharacters(in: .whitespaces)
            if trimmedParagraph.isEmpty { continue }
            
            if currentCharCount + trimmedParagraph.count > readingConfig.charactersPerPage {
                if !currentPage.isEmpty {
                    pages.append(currentPage)
                    currentPage = ""
                    currentCharCount = 0
                }
            }
            
            if !currentPage.isEmpty {
                currentPage += "\n"
                currentCharCount += 1
            }
            
            currentPage += trimmedParagraph
            currentCharCount += trimmedParagraph.count
        }
        
        if !currentPage.isEmpty {
            pages.append(currentPage)
        }
        
        return pages
    }
    
    func updateReadingProgress() {
        book.lastReadChapter = chapters.firstIndex(where: { $0.id == currentChapter?.id }) ?? 0
        book.isReading = true
        book.lastReadTime = Date()
    }
} 