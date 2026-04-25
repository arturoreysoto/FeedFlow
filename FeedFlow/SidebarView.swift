import SwiftUI

struct SidebarView: View {
    @ObservedObject var store: FeedStore
    @State private var showAddFeed = false

    var body: some View {
        List {
            Section {
                sidebarButton(
                    title: "Inbox",
                    systemImage: "tray.fill",
                    isSelected: store.selectedFeed == nil
                ) {
                    store.selectedFeed = nil
                    store.selectedArticle = nil
                }

                sidebarButton(
                    title: "Favorite Feeds",
                    systemImage: "star.circle",
                    isSelected: false
                ) {}

                sidebarButton(
                    title: "Bookmarks",
                    systemImage: "bookmark",
                    isSelected: false
                ) {}
            }
            .listRowSeparator(.hidden)

            Section {
                DisclosureGroup {
                    ForEach(store.feeds) { feed in
                        Button {
                            store.selectedFeed = feed
                            store.fetchFeed(feed: feed)
                        } label: {
                            Label {
                                Text(feed.title)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(Color(hex: "#606060"))
                            } icon: {
                                Image(systemName: "dot.radiowaves.up.forward")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color(hex: "#606060"))
                            }
                        }
                        .buttonStyle(.plain)
                        .listRowBackground(Color.clear)
                        .contextMenu {
                            Button(role: .destructive) {
                                if let index = store.feeds.firstIndex(where: { $0.id == feed.id }) {
                                    if store.selectedFeed?.id == feed.id {
                                        store.selectedFeed = nil
                                        store.selectedArticle = nil
                                    }
                                    store.feeds.remove(at: index)
                                }
                            } label: {
                                Label("Delete Feed", systemImage: "trash")
                            }
                        }
                    }
                    .onDelete { indexSet in
                        indexSet.forEach { index in
                            if store.selectedFeed?.id == store.feeds[index].id {
                                store.selectedFeed = nil
                                store.selectedArticle = nil
                            }
                        }
                        store.feeds.remove(atOffsets: indexSet)
                    }
                } label: {
                    Label {
                        Text("Feeds")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color(hex: "#606060"))
                    } icon: {
                        Image(systemName: "dot.radiowaves.up.forward")
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: "#606060"))
                    }
                }
                .listRowBackground(Color.clear)
            }
            .listRowSeparator(.hidden)
        }
        .listStyle(.sidebar)
        .background(Color(hex: "#f7f6f3"))
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button {
                    showAddFeed = true
                } label: {
                    Image(systemName: "plus.app")
                        .foregroundColor(Color(hex: "#606060"))
                }
            }
        }
        .sheet(isPresented: $showAddFeed) {
            AddFeedView(store: store, isPresented: $showAddFeed)
        }
    }

    @ViewBuilder
    private func sidebarButton(
        title: String,
        systemImage: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Label {
                Text(title)
                    .font(.system(size: 13, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(isSelected ? Color(hex: "#ff736a") : Color(hex: "#606060"))
            } icon: {
                Image(systemName: systemImage)
                    .font(.system(size: 16))
                    .foregroundColor(isSelected ? Color(hex: "#ff736a") : Color(hex: "#606060"))
            }
        }
        .buttonStyle(.plain)
        .listRowBackground(Color.clear)
    }
}

// MARK: - AddFeedView
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
        let newFeed = Feed(title: feedTitle, url: url)
        store.feeds.append(newFeed)
        store.selectedFeed = store.feeds.last
        store.fetchFeed(feed: store.feeds.last!)
        isPresented = false
    }
}
