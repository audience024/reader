import SwiftUI
import SwiftData

struct LibraryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var books: [Book]
    @State private var searchText = "" // 移除搜索栏
    @State private var showingGroupSheet = false
    @State private var showingMoreSheet = false
    @State private var showingSearchSheet = false
    
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
                        Button(action: {}) {
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
                            book.author.localizedCaseInsensitiveContains(searchText)
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
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
            }
            .frame(width: 60, height: 80)
            .cornerRadius(6)
            
            // 书籍信息
            VStack(alignment: .leading, spacing: 6) {
                Text(book.title)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(book.author)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                if let lastChapter = book.lastChapter {
                    Text("上次读到：\(lastChapter)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                if let latestChapter = book.latestChapter {
                    Text("最新章节：\(latestChapter)")
                        .font(.caption)
                        .foregroundColor(.green)
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
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Book.self, configurations: config)
    
    let sampleBook = Book(title: "示例书籍", author: "作者", sourceUrl: "https://example.com")
    container.mainContext.insert(sampleBook)
    
    return LibraryView()
        .modelContainer(container)
}
