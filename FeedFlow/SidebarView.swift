import SwiftUI

struct SidebarView: View {
    @ObservedObject var store: FeedStore

    var body: some View {
        List(selection: Binding(
            get: { store.selectedFeed?.id },
            set: { id in store.selectedFeed = store.feeds.first { $0.id == id } }
        )) {
            Section("Feeds") {
                ForEach(store.feeds) { feed in
                    Label(feed.title, systemImage: "dot.radiowaves.up.forward")
                        .tag(feed.id)
                }
            }
        }
        .listStyle(.sidebar)
        .onChange(of: store.selectedFeed?.id) {
            if let feed = store.selectedFeed {
                DispatchQueue.main.async {
                    store.fetchFeed(feed: feed)
                }
            }
        }
    }
}
