import SwiftUI

struct SubscriptionView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink {
                        Text("我的订阅")
                    } label: {
                        Label("我的订阅", systemImage: "star.fill")
                            .badge(3)
                    }
                    
                    NavigationLink {
                        Text("订阅源管理")
                    } label: {
                        Label("订阅源管理", systemImage: "gear")
                    }
                } header: {
                    Text("订阅管理")
                }
                
                Section {
                    NavigationLink {
                        Text("杂志")
                    } label: {
                        Label("杂志", systemImage: "magazine")
                    }
                    
                    NavigationLink {
                        Text("视频直播")
                    } label: {
                        Label("视频直播", systemImage: "play.tv")
                    }
                    
                    NavigationLink {
                        Text("网页游戏")
                    } label: {
                        Label("网页游戏", systemImage: "gamecontroller")
                    }
                } header: {
                    Text("内容分类")
                }
            }
            .navigationTitle("订阅")
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