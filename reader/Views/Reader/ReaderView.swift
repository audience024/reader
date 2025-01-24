import SwiftUI
import SwiftData

struct ReaderView: View {
    @State private var viewModel: ReaderViewModel
    @GestureState private var dragOffset: CGFloat = 0
    
    init(book: Book) {
        _viewModel = State(initialValue: ReaderViewModel(book: book))
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 背景色
                viewModel.readingConfig.backgroundColor
                    .ignoresSafeArea()
                
                // 内容
                VStack {
                    if let currentPage = viewModel.currentPage < viewModel.pages.count ? viewModel.pages[viewModel.currentPage] : nil {
                        ScrollView {
                            Text(currentPage)
                                .font(.system(size: viewModel.readingConfig.fontSize))
                                .foregroundColor(viewModel.readingConfig.textColor)
                                .lineSpacing(viewModel.readingConfig.lineSpacing)
                                .padding()
                        }
                    } else {
                        ProgressView()
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
            .overlay(
                HStack {
                    // 点击区域：上一页
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation {
                                _ = viewModel.previousPage()
                            }
                        }
                    
                    // 中间区域：显示菜单
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            // TODO: 显示阅读菜单
                        }
                    
                    // 点击区域：下一页
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation {
                                _ = viewModel.nextPage()
                            }
                        }
                }
            )
        }
        .task {
            do {
                try await viewModel.loadBook()
            } catch {
                print("Error loading book: \(error)")
                // TODO: 显示错误提示
            }
        }
        .onDisappear {
            viewModel.updateReadingProgress()
        }
    }
}

#Preview {
    let book = Book(title: "测试书籍", filePath: "", fileType: .txt)
    ReaderView(book: book)
        .modelContainer(for: Book.self)
} 