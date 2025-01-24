import Foundation
import CoreFoundation

class FileService {
    static let shared = FileService()
    
    private let fileManager = FileManager.default
    
    private init() {
        // 确保书籍目录存在
        do {
            try createBooksDirectory()
        } catch {
            print("创建书籍目录失败：\(error)")
        }
    }
    
    // 获取文档目录中的书籍目录
    private var booksDirectory: URL {
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsDirectory.appendingPathComponent("Books", isDirectory: true)
    }
    
    // 创建书籍目录
    private func createBooksDirectory() throws {
        let directory = booksDirectory
        print("书籍目录路径：\(directory.path)")
        
        if !fileManager.fileExists(atPath: directory.path) {
            print("创建书籍目录...")
            try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
            print("书籍目录创建成功")
        } else {
            print("书籍目录已存在")
        }
    }
    
    // 导入书籍文件
    func importBook(from sourceURL: URL) async throws -> URL {
        print("开始导入文件：\(sourceURL.path)")
        
        // 确保书籍目录存在
        try createBooksDirectory()
        
        let fileName = sourceURL.lastPathComponent
        let destinationURL = booksDirectory.appendingPathComponent(fileName)
        print("目标路径：\(destinationURL.path)")
        
        if fileManager.fileExists(atPath: destinationURL.path) {
            print("文件已存在：\(destinationURL.path)")
            throw ReaderError.importError("文件已存在：\(fileName)")
        }
        
        do {
            try fileManager.copyItem(at: sourceURL, to: destinationURL)
            print("文件复制成功：\(destinationURL.path)")
        } catch {
            print("文件复制失败：\(error)")
            throw ReaderError.importError("文件复制失败：\(error.localizedDescription)")
        }
        
        // 验证文件是否存在
        if !fileManager.fileExists(atPath: destinationURL.path) {
            print("文件复制后不存在：\(destinationURL.path)")
            throw ReaderError.importError("文件复制失败")
        }
        
        // 验证文件是否可读
        if !fileManager.isReadableFile(atPath: destinationURL.path) {
            print("文件不可读：\(destinationURL.path)")
            throw ReaderError.importError("文件不可读")
        }
        
        return destinationURL
    }
    
    // 删除书籍文件
    func deleteBook(at url: URL) throws {
        guard url.path.starts(with: booksDirectory.path) else {
            throw ReaderError.storageError("无法删除非书籍目录中的文件")
        }
        
        try fileManager.removeItem(at: url)
    }
    
    // 检测文件编码
    func detectEncoding(of url: URL) throws -> String.Encoding {
        print("检测文件编码：\(url.path)")
        
        guard fileManager.fileExists(atPath: url.path) else {
            print("文件不存在：\(url.path)")
            throw ReaderError.readError("文件不存在")
        }
        
        guard fileManager.isReadableFile(atPath: url.path) else {
            print("文件不可读：\(url.path)")
            throw ReaderError.readError("文件不可读")
        }
        
        guard let data = try? Data(contentsOf: url) else {
            print("无法读取文件内容：\(url.path)")
            throw ReaderError.readError("无法读取文件")
        }
        
        // 尝试常见编码
        let encodings: [String.Encoding] = [
            .utf8,
            .init(rawValue: CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue))),
            .init(rawValue: CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.big5.rawValue))),
            .init(rawValue: CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_2312_80.rawValue))),
            .ascii,
            .unicode
        ]
        
        for encoding in encodings {
            if let _ = String(data: data, encoding: encoding) {
                print("检测到编码：\(encoding)")
                return encoding
            }
        }
        
        print("未检测到合适的编码，使用默认编码：UTF-8")
        return .utf8
    }
    
    // 获取文件大小
    func fileSize(at url: URL) throws -> Int64 {
        guard let attributes = try? fileManager.attributesOfItem(atPath: url.path) else {
            throw ReaderError.readError("无法获取文件属性")
        }
        
        return attributes[.size] as? Int64 ?? 0
    }
} 