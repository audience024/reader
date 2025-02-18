import SwiftUI
import SwiftData

struct ReaderView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: ReaderViewModel
    @State private var showingTopBar = true
    @State private var showingBottomBar = true
    @State private var showingMenu = false
    @State private var showingError = false
    @State private var showingChapterList = false
    @State private var hostingController: ReaderHostingController<AnyView>?
    
    // 手势状态
    @GestureState private var dragOffset: CGFloat = 0
    @State private var lastTapPosition: CGPoint = .zero
    
    init(book: Book) {
        _viewModel = StateObject(wrappedValue: ReaderViewModel(book: book))
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                // 背景色
                viewModel.readingConfig.backgroundColor
                    .ignoresSafeArea(.container, edges: [.leading, .trailing])
                
                // 内容区域
                VStack(spacing: 0) {
                    // 顶部安全区域
                    Color.clear
                        .frame(height: geometry.safeAreaInsets.top + 40)
                    
                    // 主要内容
                    if viewModel.isLoading {
                        ProgressView("加载中...")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if let error = viewModel.error {
                        ErrorView(error: error) {
                            Task {
                                try? await viewModel.loadBook()
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        // 阅读内容
                        ZStack {
                            if let currentPage = viewModel.currentPage < viewModel.pages.count ? viewModel.pages[viewModel.currentPage] : nil {
                                ScrollView {
                                    Text(currentPage)
                                        .font(.system(size: viewModel.readingConfig.fontSize))
                                        .foregroundColor(viewModel.readingConfig.textColor)
                                        .lineSpacing(viewModel.readingConfig.lineSpacing)
                                        .padding(viewModel.readingConfig.pageMargins)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                }
                                .scrollDisabled(true)
                            } else {
                                Text("无内容")
                                    .foregroundColor(.secondary)
                            }
                            
                            // 点击区域
                            HStack {
                                // 左侧点击区域 - 上一页
                                Rectangle()
                                    .contentShape(Rectangle())
                                    .opacity(0.001)
                                    .onTapGesture {
                                        withAnimation {
                                            _ = viewModel.previousPage()
                                        }
                                    }
                                
                                // 中间点击区域 - 显示/隐藏工具栏
                                Rectangle()
                                    .contentShape(Rectangle())
                                    .opacity(0.001)
                                    .onTapGesture {
                                        withAnimation(.easeInOut(duration: 0.25)) {
                                            showingTopBar.toggle()
                                            showingBottomBar.toggle()
                                            // 不再隐藏状态栏，保持其始终可见
                                        }
                                    }
                                
                                // 右侧点击区域 - 下一页
                                Rectangle()
                                    .contentShape(Rectangle())
                                    .opacity(0.001)
                                    .onTapGesture {
                                        withAnimation {
                                            _ = viewModel.nextPage()
                                        }
                                    }
                            }
                        }
                        .gesture(
                            DragGesture()
                                .updating($dragOffset) { value, state, _ in
                                    state = value.translation.width
                                }
                                .onEnded { value in
                                    let threshold = geometry.size.width * 0.2
                                    if value.translation.width > threshold {
                                        // 向右滑动，上一页
                                        withAnimation {
                                            _ = viewModel.previousPage()
                                        }
                                    } else if value.translation.width < -threshold {
                                        // 向左滑动，下一页
                                        withAnimation {
                                            _ = viewModel.nextPage()
                                        }
                                    }
                                }
                        )
                    }
                }
                .safeAreaInset(edge: .top) {
                    if showingTopBar {
                        Color.clear.frame(height: geometry.safeAreaInsets.top + 44)
                    }
                }
                
                // 工具栏容器
                VStack(spacing: 0) {
                    // 顶部工具栏
                    TopBar(
                        title: viewModel.book.title,
                        chapterTitle: viewModel.currentChapter?.title,
                        isVisible: showingTopBar,
                        onBack: {
                            viewModel.updateReadingProgress()
                            dismiss()
                            UIApplication.shared.firstKeyWindow?.rootViewController?.dismiss(animated: true)
                        },
                        showingChapterList: $showingChapterList
                    )
                    .padding(.top, geometry.safeAreaInsets.top + 44)
                    
                    Spacer()
                    
                    // 底部工具栏
                    BottomBar(
                        currentPage: viewModel.currentPage,
                        totalPages: viewModel.totalPages,
                        isVisible: showingBottomBar,
                        onPageChanged: { page in
                            viewModel.currentPage = page
                        },
                        viewModel: viewModel,
                        showingChapterList: $showingChapterList
                    )
                }
                .ignoresSafeArea(.container, edges: [.bottom])
            }
        }
        .preferredColorScheme(viewModel.readingConfig.isNightMode ? .dark : .light)
        .ignoresSafeArea(.container, edges: .bottom)
        .task {
            do {
                try await viewModel.loadBook()
            } catch {
                showingError = true
            }
        }
        .alert("加载失败", isPresented: $showingError) {
            Button("确定", role: .cancel) {}
            Button("重试") {
                Task {
                    try? await viewModel.loadBook()
                }
            }
        } message: {
            if let error = viewModel.error {
                Text(error.localizedDescription)
            }
        }
        .onDisappear {
            viewModel.updateReadingProgress()
        }
        .sheet(isPresented: $showingChapterList) {
            ChapterListView(
                chapters: viewModel.chapters,
                currentChapterIndex: viewModel.currentChapterIndex,
                onChapterSelected: { index in
                    Task {
                        try? await viewModel.jumpToChapter(at: index)
                    }
                }
            )
        }
        .background {
            Color.clear.onAppear {
                let hostingController = ReaderHostingController(rootView: AnyView(EmptyView()))
                self.hostingController = hostingController
            }
        }
    }
}

// 顶部工具栏
struct TopBar: View {
    let title: String
    let chapterTitle: String?
    let isVisible: Bool
    let onBack: () -> Void
    @Binding var showingChapterList: Bool
    
    var body: some View {
        Group {
            if isVisible {
                VStack(spacing: 0) {
                    // 工具栏
                    HStack(spacing: 16) {
                        // 返回按钮
                        Button(action: onBack) {
                            Image(systemName: "chevron.left")
                        }
                        
                        // 书籍信息
                        VStack(alignment: .leading, spacing: 2) {
                            Text(title)
                                .font(.headline)
                            if let chapterTitle = chapterTitle {
                                Text(chapterTitle)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        // 功能按钮
                        HStack(spacing: 20) {
                            Button(action: {}) {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                    .help("换源")
                            }
                            
                            Button(action: {}) {
                                Image(systemName: "arrow.clockwise")
                                    .help("刷新")
                            }
                            
                            Button(action: {}) {
                                Image(systemName: "arrow.down.circle")
                                    .help("离线缓存")
                            }
                            
                            Button(action: {}) {
                                Image(systemName: "ellipsis")
                                    .help("更多选项")
                            }
                        }
                    }
                    .padding(.horizontal)
                    .frame(height: 44)
                    .background(.ultraThinMaterial)
                }
                .background(.ultraThinMaterial)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }
}

// 底部工具栏
struct BottomBar: View {
    let currentPage: Int
    let totalPages: Int
    let isVisible: Bool
    let onPageChanged: (Int) -> Void
    let viewModel: ReaderViewModel
    @Binding var showingChapterList: Bool
    
    var body: some View {
        Group {
            if isVisible {
                VStack(spacing: 0) {
                    // 进度条
                    if totalPages > 0 {
                        HStack {
                            Button(action: {
                                Task {
                                    try? await viewModel.previousChapter()
                                }
                            }) {
                                Text("上一章")
                                    .font(.caption)
                            }
                            
                            Slider(
                                value: .init(
                                    get: { Double(currentPage) },
                                    set: { onPageChanged(Int($0)) }
                                ),
                                in: 0...Double(max(totalPages - 1, 1)),
                                step: 1
                            )
                            
                            Button(action: {
                                Task {
                                    try? await viewModel.nextChapter()
                                }
                            }) {
                                Text("下一章")
                                    .font(.caption)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // 工具栏
                    HStack {
                        // 左侧按钮组
                        HStack(spacing: 24) {
                            Button(action: {
                                showingChapterList = true
                            }) {
                                Image(systemName: "list.bullet")
                                    .help("目录")
                            }
                        }
                        
                        Spacer()
                        
                        // 右侧按钮组
                        HStack(spacing: 24) {
                            Button(action: {}) {
                                Image(systemName: "wand.and.stars")
                                    .help("替换净化")
                            }
                            
                            Button(action: {}) {
                                Image(systemName: "moon")
                                    .help("深色模式")
                            }
                            
                            Button(action: {}) {
                                Image(systemName: "textformat")
                                    .help("界面设置")
                            }
                            
                            Button(action: {}) {
                                Image(systemName: "gear")
                                    .help("设置")
                            }
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }
}

// 错误视图
struct ErrorView: View {
    let error: Error
    let retry: () -> Void
    
    var body: some View {
        VStack {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.red)
            Text("加载失败")
                .font(.headline)
                .padding(.top)
            Text(error.localizedDescription)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()
            Button("重试", action: retry)
                .buttonStyle(.bordered)
        }
        .padding()
    }
}

#Preview {
    let book = Book(title: "测试书籍", filePath: "", fileType: .txt)
    return ReaderView(book: book)
        .modelContainer(for: Book.self)
}