import SwiftUI

struct ContentView: View {
    @StateObject private var store = FeedStore()

    var body: some View {
        NavigationSplitView {
            SidebarView(store: store)
                .navigationSplitViewColumnWidth(min: 200, ideal: 242)
        } content: {
            ArticleListView(store: store)
                .navigationSplitViewColumnWidth(min: 260, ideal: 300)
        } detail: {
            ArticleDetailView(store: store)
        }
        .background(Color(hex: "#F7F6F3"))
    }
}
