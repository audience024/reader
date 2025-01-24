import Foundation

enum ReaderError: LocalizedError {
    case fileNotFound(String)
    case invalidEncoding(String)
    case parseError(String)
    case readError(String)
    case importError(String)
    case storageError(String)
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound(let path):
            return "找不到文件：\(path)"
        case .invalidEncoding(let message):
            return "文件编码错误：\(message)"
        case .parseError(let message):
            return "解析错误：\(message)"
        case .readError(let message):
            return "读取错误：\(message)"
        case .importError(let message):
            return "导入错误：\(message)"
        case .storageError(let message):
            return "存储错误：\(message)"
        }
    }
} 