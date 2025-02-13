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

@MainActor
class ReaderViewModel: ObservableObject {
    private var parser: any BookParserProtocol
    let book: Book
    @Published private(set) var chapters: [Chapter] = []
    
    @Published var currentChapter: Chapter?
    @Published var currentPage: Int = 0
    @Published var totalPages: Int = 0
    @Published var pages: [String] = []
    @Published var isLoading = false
    @Published var error: Error?
    
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
        isLoading = true
        error = nil
        
        defer { isLoading = false }
        
        do {
            // 验证文件是否存在
            guard FileManager.default.fileExists(atPath: book.filePath) else {
                throw BookParserError.fileNotFound
            }
            
            print("开始加载书籍：\(book.title)")
            print("文件路径：\(book.filePath)")
            
            chapters = try await parser.parseChapters(for: book)
            print("解析到 \(chapters.count) 个章节")
            
            // 如果有上次阅读记录，从上次位置开始
            if book.isReading, book.lastReadChapter < chapters.count {
                let chapter = chapters[book.lastReadChapter]
                print("从上次阅读位置继续：\(chapter.title)")
                try await loadChapter(chapter)
            } else if let firstChapter = chapters.first {
                print("加载第一章：\(firstChapter.title)")
                try await loadChapter(firstChapter)
            } else {
                print("没有找到任何章节")
                throw BookParserError.parseError("没有找到任何章节")
            }
            
            print("章节内容长度：\(pages.joined().count) 字符")
            print("分页数量：\(pages.count)")
        } catch {
            print("加载书籍失败：\(error)")
            self.error = error
            throw error
        }
    }
    
    func loadChapter(_ chapter: Chapter) async throws {
        print("加载章节：\(chapter.title)")
        currentChapter = chapter
        let content = try await parser.loadChapterContent(chapter)
        print("章节内容长度：\(content.count)")
        pages = paginateContent(content)
        currentPage = 0
        totalPages = pages.count
        print("分页完成，共 \(pages.count) 页")
    }
    
    func nextPage() -> Bool {
        guard currentPage < totalPages - 1 else {
            // 如果是最后一页，尝试加载下一章
            Task {
                try? await nextChapter()
            }
            return false
        }
        currentPage += 1
        return true
    }
    
    func previousPage() -> Bool {
        guard currentPage > 0 else {
            // 如果是第一页，尝试加载上一章
            Task {
                try? await previousChapter()
            }
            return false
        }
        currentPage -= 1
        return true
    }
    
    func nextChapter() async throws {
        guard let currentChapter = currentChapter,
              let currentIndex = chapters.firstIndex(where: { $0.id == currentChapter.id }),
              currentIndex < chapters.count - 1 else {
            return
        }
        
        let nextChapter = chapters[currentIndex + 1]
        try await loadChapter(nextChapter)
    }
    
    func previousChapter() async throws {
        guard let currentChapter = currentChapter,
              let currentIndex = chapters.firstIndex(where: { $0.id == currentChapter.id }),
              currentIndex > 0 else {
            return
        }
        
        let previousChapter = chapters[currentIndex - 1]
        try await loadChapter(previousChapter)
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
        guard let currentChapter = currentChapter,
              let chapterIndex = chapters.firstIndex(where: { $0.id == currentChapter.id }) else {
            return
        }
        
        book.lastReadChapter = chapterIndex
        book.isReading = true
        book.lastReadTime = Date()
    }
} 