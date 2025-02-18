import SwiftUI

struct ChapterListView: View {
    @Environment(\.dismiss) private var dismiss
    let chapters: [Chapter]
    let currentChapterIndex: Int
    let onChapterSelected: (Int) -> Void
    @State private var selectedTab = 0
    @State private var showingSearch = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 顶部标签页
                HStack(spacing: 0) {
                    TabButton(
                        title: "目录",
                        icon: "list.bullet",
                        isSelected: selectedTab == 0
                    ) {
                        selectedTab = 0
                    }
                    
                    TabButton(
                        title: "书签",
                        icon: "bookmark",
                        isSelected: selectedTab == 1
                    ) {
                        selectedTab = 1
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                
                Divider()
                
                if selectedTab == 0 {
                    // 章节列表
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(Array(chapters.enumerated()), id: \.element.id) { index, chapter in
                                Button(action: {
                                    onChapterSelected(index)
                                    dismiss()
                                }) {
                                    HStack(spacing: 12) {
                                        // 章节标题
                                        Text("第\(index + 1)章 \(chapter.title)")
                                            .foregroundColor(index == currentChapterIndex ? .blue : .primary)
                                            .font(.system(size: 16))
                                            .lineLimit(1)
                                        
                                        Spacer()
                                        
                                        // 状态图标
                                        if index == currentChapterIndex {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(.blue)
                                        } else {
                                            Image(systemName: "icloud.and.arrow.down")
                                                .foregroundColor(.gray.opacity(0.5))
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .frame(height: 50)
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                                
                                if index < chapters.count - 1 {
                                    Divider()
                                        .padding(.leading, 16)
                                }
                            }
                        }
                    }
                    
                    // 底部当前章节信息
                    if currentChapterIndex < chapters.count {
                        Divider()
                        HStack {
                            Text("第\(currentChapterIndex + 1)章 \(chapters[currentChapterIndex].title)")
                                .lineLimit(1)
                            Spacer()
                            Text("(\(currentChapterIndex + 1)/\(chapters.count))")
                        }
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(.ultraThinMaterial)
                    }
                } else {
                    // 书签页面
                    VStack {
                        Image(systemName: "bookmark.slash")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)
                            .padding(.bottom, 8)
                        Text("暂无书签")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle("目录")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showingSearch = true
                    }) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.blue)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("关闭") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
            }
        }
    }
}

// 自定义标签按钮
struct TabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                Text(title)
                    .font(.system(size: 16))
            }
            .frame(maxWidth: .infinity)
            .foregroundColor(isSelected ? .blue : .gray)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
    }
} 