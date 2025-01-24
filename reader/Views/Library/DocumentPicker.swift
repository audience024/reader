import SwiftUI
import UniformTypeIdentifiers

struct DocumentPicker: UIViewControllerRepresentable {
    let types: [UTType]
    let completion: (Result<URL, Error>) -> Void
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: types)
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(completion: completion)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let completion: (Result<URL, Error>) -> Void
        
        init(completion: @escaping (Result<URL, Error>) -> Void) {
            self.completion = completion
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else {
                completion(.failure(NSError(domain: "DocumentPicker", code: -1, userInfo: [NSLocalizedDescriptionKey: "没有选择文件"])))
                return
            }
            
            // 获取文件访问权限
            guard url.startAccessingSecurityScopedResource() else {
                completion(.failure(NSError(domain: "DocumentPicker", code: -2, userInfo: [NSLocalizedDescriptionKey: "无法访问文件"])))
                return
            }
            
            defer { url.stopAccessingSecurityScopedResource() }
            completion(.success(url))
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            completion(.failure(NSError(domain: "DocumentPicker", code: -3, userInfo: [NSLocalizedDescriptionKey: "取消选择"])))
        }
    }
} 