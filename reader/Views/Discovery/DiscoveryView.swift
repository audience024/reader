import SwiftUI

struct DiscoveryView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink {
                        Text("周榜")
                    } label: {
                        Label("周榜", systemImage: "chart.bar.fill")
                    }
                    
                    NavigationLink {
                        Text("月榜")
                    } label: {
                        Label("月榜", systemImage: "chart.line.uptrend.xyaxis")
                    }
                    
                    NavigationLink {
                        Text("总榜")
                    } label: {
                        Label("总榜", systemImage: "rosette")
                    }
                } header: {
                    Text("排行榜")
                }
                
                Section {
                    NavigationLink {
                        Text("玄幻")
                    } label: {
                        Label("玄幻", systemImage: "wand.and.stars")
                    }
                    
                    NavigationLink {
                        Text("修真")
                    } label: {
                        Label("修真", systemImage: "sparkles")
                    }
                    
                    NavigationLink {
                        Text("都市")
                    } label: {
                        Label("都市", systemImage: "building.2")
                    }
                    
                    NavigationLink {
                        Text("历史")
                    } label: {
                        Label("历史", systemImage: "scroll")
                    }
                } header: {
                    Text("分类")
                }
            }
            .navigationTitle("发现")
        }
        .enableInjection()
    }
    
    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
}

#Preview {
    DiscoveryView()
}