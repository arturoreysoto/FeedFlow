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
        .background(Color(red: 0.969, green: 0.965, blue: 0.953))
    }
}
