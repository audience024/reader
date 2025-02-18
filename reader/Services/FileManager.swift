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
    
    // 导入书籍文件到应用沙盒
    func importBook(from sourceURL: URL) throws -> URL {
        // 确保源文件存在
        guard fileManager.fileExists(atPath: sourceURL.path) else {
            print("源文件不存在：\(sourceURL.path)")
            throw ReaderError.importError("源文件不存在")
        }
        
        let fileName = sourceURL.lastPathComponent
        let destinationURL = booksDirectory.appendingPathComponent(fileName)
        
        // 如果目标文件已存在，先删除
        if fileManager.fileExists(atPath: destinationURL.path) {
            try fileManager.removeItem(at: destinationURL)
        }
        
        // 复制文件到书籍目录
        try fileManager.copyItem(at: sourceURL, to: destinationURL)
        print("书籍文件已复制到：\(destinationURL.path)")
        
        // 验证文件是否成功复制
        guard fileManager.fileExists(atPath: destinationURL.path) else {
            print("文件复制失败，目标文件不存在：\(destinationURL.path)")
            throw ReaderError.importError("文件复制失败")
        }
        
        // 验证文件是否可读
        guard fileManager.isReadableFile(atPath: destinationURL.path) else {
            print("目标文件不可读：\(destinationURL.path)")
            throw ReaderError.importError("文件不可读")
        }
        
        return destinationURL
    }
    
    // 创建书籍目录
    private func createBooksDirectory() throws {
        let directory = booksDirectory
        print("书籍目录路径：\(directory.path)")
        
        var isDirectory: ObjCBool = false
        let exists = fileManager.fileExists(atPath: directory.path, isDirectory: &isDirectory)
        
        if !exists {
            print("创建书籍目录...")
            try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
            print("书籍目录创建成功")
        } else if !isDirectory.boolValue {
            print("路径存在但不是目录，删除并重新创建...")
            try fileManager.removeItem(at: directory)
            try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
            print("书籍目录创建成功")
        } else {
            print("书籍目录已存在")
        }
        
        // 验证目录权限
        if !fileManager.isWritableFile(atPath: directory.path) {
            print("警告：书籍目录不可写")
            throw ReaderError.storageError("书籍目录不可写")
        }
    }
    
    // 检查文件是否存在
    func fileExists(at path: String) -> Bool {
        return fileManager.fileExists(atPath: path)
    }
    
    // 获取文件内容
    func readFile(at path: String) throws -> Data {
        return try Data(contentsOf: URL(fileURLWithPath: path))
    }
    
    // 删除书籍文件
    func deleteBook(at url: URL) throws {
        // 获取文件名
        let fileName = url.lastPathComponent
        let targetPath = booksDirectory.appendingPathComponent(fileName).path
        
        // 如果文件存在于当前的书籍目录中，则删除它
        if FileManager.default.fileExists(atPath: targetPath) {
            try FileManager.default.removeItem(atPath: targetPath)
            print("文件删除成功：\(targetPath)")
        } else {
            // 如果文件不在当前书籍目录中，尝试删除原始路径
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
                print("文件删除成功：\(url.path)")
            } else {
                print("文件不存在：\(url.path)")
                // 如果文件已经不存在，我们认为删除是成功的
            }
        }
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
        
        print("成功读取文件，大小：\(data.count) 字节")
        
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