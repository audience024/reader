import SwiftUI
import SwiftData

struct MainTabView: View {
    var body: some View {
        TabView {
            LibraryView()
                .tabItem {
                    Label("书架", systemImage: "books.vertical")
                }
            
            DiscoveryView()
                .tabItem {
                    Label("发现", systemImage: "safari")
                }
            
            SubscriptionView()
                .tabItem {
                    Label("订阅", systemImage: "newspaper")
                }
            
            ProfileView()
                .tabItem {
                    Label("我的", systemImage: "person")
                }
        }
    }
}

struct LibraryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var books: [Book]
    @State private var searchText = ""
    @State private var showingGroupSheet = false
    @State private var showingMoreSheet = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 搜索栏
                SearchBar(text: $searchText)
                    .padding()
                
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
            .navigationTitle("书架")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showingGroupSheet = true }) {
                        Image(systemName: "folder")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingMoreSheet = true }) {
                        Image(systemName: "ellipsis.circle")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "magnifyingglass")
                    }
                }
            }
            .sheet(isPresented: $showingGroupSheet) {
                NavigationStack {
                    List {
                        Text("全部")
                        Text("未分组")
                        Text("收藏")
                    }
                    .navigationTitle("选择分组")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("完成") {
                                showingGroupSheet = false
                            }
                        }
                    }
                }
                .presentationDetents([.medium])
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

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Book.self, configurations: config)
    
    let sampleBook = Book(title: "示例书籍", author: "作者", sourceUrl: "https://example.com")
    container.mainContext.insert(sampleBook)
    
    return LibraryView()
        .modelContainer(container)
}