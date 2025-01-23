import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationStack {
            List {
                // 书源和内容管理
                Section {
                    NavigationLink {
                        Text("书源管理")
                    } label: {
                        Label("书源管理", systemImage: "doc.text.magnifyingglass")
                            .badge(1)
                    }
                    
                    NavigationLink {
                        Text("替换净化")
                    } label: {
                        Label("替换净化", systemImage: "arrow.triangle.2.circlepath")
                            .badge(2)
                    }
                } header: {
                    Text("书源和内容管理")
                }
                
                // 应用设置
                Section {
                    NavigationLink {
                        Text("主题模式")
                    } label: {
                        Label("主题模式", systemImage: "circle.lefthalf.filled")
                            .badge(3)
                    }
                    
                    NavigationLink {
                        Text("Web服务")
                    } label: {
                        Label("Web服务", systemImage: "network")
                            .badge(4)
                    }
                    
                    NavigationLink {
                        Text("备份与恢复")
                    } label: {
                        Label("备份与恢复", systemImage: "arrow.triangle.2.circlepath.circle")
                            .badge(5)
                    }
                    
                    NavigationLink {
                        Text("主题设置")
                    } label: {
                        Label("主题设置", systemImage: "paintpalette")
                            .badge(6)
                    }
                    
                    NavigationLink {
                        Text("其它设置")
                    } label: {
                        Label("其它设置", systemImage: "gearshape")
                            .badge(7)
                    }
                } header: {
                    Text("应用设置")
                }
                
                // 信息查看
                Section {
                    NavigationLink {
                        Text("阅读记录")
                    } label: {
                        Label("阅读记录", systemImage: "clock")
                            .badge(8)
                    }
                    
                    NavigationLink {
                        Text("关于")
                    } label: {
                        Label("关于", systemImage: "info.circle")
                            .badge(9)
                    }
                } header: {
                    Text("信息查看")
                }
            }
            .navigationTitle("我的")
        }
        .enableInjection()
    }
    
    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
}

#Preview {
    ProfileView()
}