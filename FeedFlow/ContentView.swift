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
                .navigationTitle("Inbox")
        } detail: {
            ArticleDetailView(store: store)
        }
        .navigationSplitViewStyle(.balanced)
        .background(Color(hex: "#FFFDF8"))
        .toolbar(removing: .sidebarToggle)
        .toolbarBackground(.hidden, for: .windowToolbar)
    }
}
