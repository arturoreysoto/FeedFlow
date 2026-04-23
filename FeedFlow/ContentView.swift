import SwiftUI

struct ContentView: View {
    @StateObject private var store = FeedStore()

    var body: some View {
        NavigationSplitView {
            SidebarView(store: store)
                .navigationSplitViewColumnWidth(min: 180, ideal: 220)
        } content: {
            ArticleListView(store: store)
                .navigationSplitViewColumnWidth(min: 280, ideal: 320)
        } detail: {
            ArticleDetailView(store: store)
        }
        .navigationTitle("FeedFlow")
    }
}
