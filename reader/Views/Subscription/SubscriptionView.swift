import SwiftUI

struct SubscriptionView: View {
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 顶部工具栏
                HStack(spacing: 12) {
                    // 搜索栏
                    SearchBar(text: $searchText)
                    
                    // 功能按钮
                    Button(action: {}) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                    }
                    
                    Button(action: {}) {
                        Image(systemName: "folder")
                            .foregroundColor(.blue)
                    }
                    
                    Button(action: {}) {
                        Image(systemName: "gearshape")
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                
                List {
                    // 订阅源管理
                    Section {
                        NavigationLink {
                            Text("收藏夹")
                        } label: {
                            Label("收藏夹", systemImage: "star.fill")
                        }
                        
                        NavigationLink {
                            Text("分组管理")
                        } label: {
                            Label("分组管理", systemImage: "folder")
                        }
                    } header: {
                        Text("订阅源管理")
                    }
                    
                    // 订阅源设置
                    Section {
                        NavigationLink {
                            Text("新建订阅源")
                        } label: {
                            Label("新建订阅源", systemImage: "plus.circle")
                        }
                        
                        NavigationLink {
                            Text("订阅源设置")
                        } label: {
                            Label("订阅源设置", systemImage: "gearshape")
                        }
                    } header: {
                        Text("订阅源设置")
                    }
                    
                    // 网络内容
                    Section {
                        NavigationLink {
                            Text("RSS订阅")
                        } label: {
                            Label("RSS订阅", systemImage: "dot.radiowaves.left.and.right")
                        }
                        
                        NavigationLink {
                            Text("网页内容")
                        } label: {
                            Label("网页内容", systemImage: "safari")
                        }
                        
                        NavigationLink {
                            Text("其他来源")
                        } label: {
                            Label("其他来源", systemImage: "network")
                        }
                    } header: {
                        Text("订阅源")
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

#Preview {
    SubscriptionView()
}
