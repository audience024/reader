import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct LibraryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var books: [Book]
    @State private var searchText = "" // 移除搜索栏
    @State private var showingGroupSheet = false
    @State private var showingMoreSheet = false
    @State private var showingSearchSheet = false
    @State private var showingFilePicker = false
    @State private var importError: Error?
    @State private var showingErrorAlert = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 分组
                VStack(spacing: 0) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            GroupButton(title: "全部", count: books.count)
                            GroupButton(title: "未分组", count: books.filter { $0.groupName == nil }.count)
                            GroupButton(title: "收藏", count: books.filter { $0.isFavorite }.count)
                            GroupButton(title: "在看", count: books.filter { $0.isReading }.count)
                            GroupButton(title: "未看", count: books.filter { !$0.isReading }.count)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 8)
                    
                    
                }
                .background(Color(.systemBackground))
                
                List {
                    ForEach(books) { book in
                        NavigationLink(destination: ReaderView(book: book)) {
                            BookRowView(book: book)
                                .contextMenu {
                                    Button(action: {}) {
                                        Label("查看详情", systemImage: "info.circle")
                                    }
                                    Button(action: {}) {
                                        Label("下载", systemImage: "arrow.down.circle")
                                    }
                                    Button(action: {}) {
                                        Label("移动到分组", systemImage: "folder")
                                    }
                                }
                        }
                    }
                }
            }
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingSearchSheet = true }) {
                        Image(systemName: "magnifyingglass")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingMoreSheet = true }) {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showingMoreSheet) {
                NavigationStack {
                    List {
                        Button(action: { showingFilePicker = true }) {
                            Label("添加本地书籍", systemImage: "doc.badge.plus")
                        }
                        Button(action: {}) {
                            Label("整理书架", systemImage: "square.grid.2x2")
                        }
                        Button(action: {}) {
                            Label("管理分组", systemImage: "folder.badge.plus")
                        }
                    }
                    .navigationTitle("更多操作")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("完成") {
                                showingMoreSheet = false
                            }
                        }
                    }
                }
                .presentationDetents([.medium])
            }
            .sheet(isPresented: $showingSearchSheet) {
                NavigationStack {
                    List {
                        ForEach(books.filter { book in
                            searchText.isEmpty ||
                            book.title.localizedCaseInsensitiveContains(searchText) ||
                            (book.author?.localizedCaseInsensitiveContains(searchText) ?? false)
                        }) { book in
                            BookRowView(book: book)
                        }
                    }
                    .searchable(text: $searchText, prompt: "搜索书名或作者")
                    .navigationTitle("搜索")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("完成") {
                                showingSearchSheet = false
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $showingFilePicker) {
                DocumentPicker(types: [.text]) { result in
                    switch result {
                    case .success(let url):
                        Task {
                            do {
                                let fileService = FileService.shared
                                let bookUrl = try await fileService.importBook(from: url)
                                let encoding = try fileService.detectEncoding(of: bookUrl)
                                
                                let book = Book(
                                    title: url.deletingPathExtension().lastPathComponent,
                                    filePath: bookUrl.path,
                                    fileType: .txt,
                                    encoding: encoding,
                                    isLocal: true
                                )
                                
                                modelContext.insert(book)
                                try modelContext.save()
                                
                            } catch {
                                importError = error
                                showingErrorAlert = true
                            }
                        }
                    case .failure(let error):
                        importError = error
                        showingErrorAlert = true
                    }
                }
            }
            .alert("导入失败", isPresented: $showingErrorAlert, presenting: importError) { _ in
                Button("确定", role: .cancel) {}
            } message: { error in
                Text(error.localizedDescription)
            }
        }
        .enableInjection()
    }
    
    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
}

struct BookRowView: View {
    let book: Book
    
    var body: some View {
        HStack(spacing: 12) {
            // 封面图
            AsyncImage(url: URL(string: book.coverUrl ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.gray.opacity(0.2))
            }
            .frame(width: 60, height: 80)
            .cornerRadius(6)
            
            // 书籍信息
            VStack(alignment: .leading, spacing: 6) {
                Text(book.title)
                    .font(.headline)
                    .lineLimit(1)
                
                if let author = book.author {
                    Text(author)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                if book.isReading {
                    Text("阅读至：第\(book.lastReadChapter + 1)章")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                if let lastReadTime = book.lastReadTime {
                    Text("最近阅读：\(lastReadTime.formatted(.relative(presentation: .named)))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 8)
    }
}

struct GroupButton: View {
    let title: String
    let count: Int
    
    var body: some View {
        HStack(spacing: 4) {
            Text(title)
                .font(.subheadline)
            Text("\(count)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
}

#Preview {
    LibraryView()
        .modelContainer(for: Book.self)
}
