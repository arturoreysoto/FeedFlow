import SwiftUI

struct SidebarView: View {
    @ObservedObject var store: FeedStore
    @State private var showAddFeed = false

    var body: some View {
        List {
            Section("Feeds") {
                Button {
                    store.selectedFeed = nil
                } label: {
                    Label("Inbox", systemImage: "tray.and.arrow.down")
                }

                Button {
                    store.flowRandom()
                } label: {
                    Label("Flow", systemImage: "shuffle")
                }

                Button {} label: {
                    Label("Flow Feeds", systemImage: "square.grid.2x2")
                }

                ForEach(store.feeds) { feed in
                    Button {
                        store.selectedFeed = feed
                        store.fetchFeed(feed: feed)
                    } label: {
                        Label(feed.title, systemImage: "dot.radiowaves.up.forward")
                    }
                    .contextMenu {
                        Button(role: .destructive) {
                            if let index = store.feeds.firstIndex(where: { $0.id == feed.id }) {
                                store.feeds.remove(at: index)
                            }
                        } label: {
                            Label("Delete Feed", systemImage: "trash")
                        }
                    }
                }
                .onDelete { indexSet in
                    store.feeds.remove(atOffsets: indexSet)
                }
            }

            Section {
                Button {} label: {
                    Label("Trash", systemImage: "trash")
                }
            }
        }
        .listStyle(.sidebar)
        .toolbar {
            ToolbarItem {
                Button {
                    showAddFeed = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddFeed) {
            AddFeedView(store: store, isPresented: $showAddFeed)
        }
    }
}

struct AddFeedView: View {
    @ObservedObject var store: FeedStore
    @Binding var isPresented: Bool
    @State private var title = ""
    @State private var url = ""
    @FocusState private var urlFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button("Cancel") { isPresented = false }
                Spacer()
                Text("Add Feed").font(.system(size: 13, weight: .semibold))
                Spacer()
                Button("Add") { addFeed() }
                    .disabled(url.isEmpty)
                    .fontWeight(.semibold)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            Divider()

            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Name").font(.system(size: 12)).foregroundStyle(.secondary)
                    TextField("My Feed", text: $title).textFieldStyle(.roundedBorder)
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text("URL").font(.system(size: 12)).foregroundStyle(.secondary)
                    TextField("https://example.com/feed", text: $url)
                        .textFieldStyle(.roundedBorder)
                        .focused($urlFocused)
                }
            }
            .padding(20)
            Spacer()
        }
        .frame(width: 340, height: 220)
        .onAppear { urlFocused = true }
    }

    func addFeed() {
        let feedTitle = title.isEmpty ? url : title
        store.feeds.append(Feed(title: feedTitle, url: url))
        store.fetchFeed(feed: store.feeds.last!)
        isPresented = false
    }
}
