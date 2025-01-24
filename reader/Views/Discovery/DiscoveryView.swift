import SwiftUI

struct DiscoveryView: View {
    @State private var searchText = ""
    @State private var selectedType = "书籍"
    let types = ["书籍", "听书", "漫画"]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 搜索栏
                SearchBar(text: $searchText)
                    .padding()
                
                // 类型筛选
                Picker("内容类型", selection: $selectedType) {
                    ForEach(types, id: \.self) { type in
                        Text(type).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                List {
                    // 分类导航
                    Section {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                CategoryButton(title: "玄幻", systemImage: "wand.and.stars")
                                CategoryButton(title: "修真", systemImage: "sparkles")
                                CategoryButton(title: "都市", systemImage: "building.2")
                                CategoryButton(title: "历史", systemImage: "scroll")
                                CategoryButton(title: "科幻", systemImage: "atom")
                                CategoryButton(title: "更多", systemImage: "ellipsis.circle")
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical, 8)
                    } header: {
                        Text("分类导航")
                    }
                    
                    // 排行榜
                    Section {
                        NavigationLink {
                            Text("周榜")
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Label("周榜", systemImage: "chart.bar.fill")
                                Text("最近7天最热门的作品")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        NavigationLink {
                            Text("月榜")
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Label("月榜", systemImage: "chart.line.uptrend.xyaxis")
                                Text("本月最受欢迎的作品")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        NavigationLink {
                            Text("总榜")
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Label("总榜", systemImage: "rosette")
                                Text("历史最热门的作品")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    } header: {
                        Text("排行榜")
                    }
                }
            }
            .navigationTitle("")
        }
        .enableInjection()
    }
    
    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
}

struct CategoryButton: View {
    let title: String
    let systemImage: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: systemImage)
                .font(.title2)
                .foregroundColor(.accentColor)
                .frame(width: 44, height: 44)
                .background(Color(.systemGray6))
                .cornerRadius(12)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    DiscoveryView()
}
