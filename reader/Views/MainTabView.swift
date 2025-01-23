import SwiftUI

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

#Preview {
    MainTabView()
        .modelContainer(for: Book.self, inMemory: true)
}