import SwiftUI

struct SidebarView: View {
    @ObservedObject var store: FeedStore

    var body: some View {
        List {
            Section("Feeds") {
                SidebarRow(icon: "tray.and.arrow.down", title: "Inbox", isSelected: store.selectedFeed == nil) {
                    store.selectedFeed = nil
                }

                SidebarRow(icon: "shuffle", title: "Flow", isSelected: false) {
                    store.flowRandom()
                }

                SidebarRow(icon: "square.grid.2x2", title: "Flow Feeds", isSelected: false) {}

                ForEach(store.feeds) { feed in
                    SidebarRow(icon: "dot.radiowaves.up.forward", title: feed.title, isSelected: store.selectedFeed?.id == feed.id) {
                        store.selectedFeed = feed
                        store.fetchFeed(feed: feed)
                    }
                }
            }

            Section {
                SidebarRow(icon: "trash", title: "Trash", isSelected: false) {}
            }
        }
        .listStyle(.sidebar)
        .background(Color(hex: "#F7F6F3"))
        .scrollContentBackground(.hidden)
    }
}

struct SidebarRow: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 13))
                    .foregroundStyle(isSelected ? Color(hex: "#FF736A") : Color(hex: "#606060"))
                    .frame(width: 16)
                Text(title)
                    .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? Color(hex: "#FF736A") : Color(hex: "#606060"))
                Spacer()
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isHovered ? Color(hex: "#E8E7E4") : Color.clear)
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
        .listRowBackground(Color.clear)
    }
}
