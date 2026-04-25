import SwiftUI

struct SidebarView: View {
    @ObservedObject var store: FeedStore

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 2) {
                SidebarItem(
                    icon: "tray.and.arrow.down",
                    title: "Inbox",
                    isSelected: store.selectedFeed == nil,
                    accentColor: Color(hex: "#FF736A")
                ) {
                    store.selectedFeed = nil
                }

                SidebarItem(
                    icon: "square.grid.2x2",
                    title: "Flow Feeds",
                    isSelected: false,
                    accentColor: Color(hex: "#606060")
                ) {}

                ForEach(store.feeds) { feed in
                    SidebarItem(
                        icon: "dot.radiowaves.up.forward",
                        title: feed.title,
                        isSelected: store.selectedFeed?.id == feed.id,
                        accentColor: Color(hex: "#606060")
                    ) {
                        store.selectedFeed = feed
                        store.fetchFeed(feed: feed)
                    }
                }

                Divider()
                    .background(Color(hex: "#E9E9E7"))
                    .padding(.vertical, 8)

                SidebarItem(
                    icon: "trash",
                    title: "Trash",
                    isSelected: false,
                    accentColor: Color(hex: "#606060")
                ) {}
            }
            .padding(.horizontal, 12)
            .padding(.top, 12)

            Spacer()

            Divider()
                .background(Color(hex: "#E9E9E7"))

            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "folder")
                        .font(.system(size: 10))
                    Text("FeedFlow")
                        .font(.system(size: 10, weight: .medium))
                }
                .foregroundStyle(Color(hex: "#606060"))

                Spacer()

                Divider()
                    .frame(height: 16)

                HStack(spacing: 4) {
                    Image(systemName: "arrow.clockwise.circle")
                        .font(.system(size: 10))
                    Text("Release v1.0.0")
                        .font(.system(size: 10, weight: .medium))
                }
                .foregroundStyle(Color(hex: "#606060"))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .background(Color(hex: "#F7F6F3"))
    }
}

struct SidebarItem: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let accentColor: Color
    let action: () -> Void
    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(isSelected ? Color(hex: "#FF736A") : Color(hex: "#606060"))
                    .frame(width: 16)

                Text(title)
                    .font(.system(size: 14, weight: isSelected ? .bold : .medium))
                    .foregroundStyle(isSelected ? Color(hex: "#FF736A") : Color(hex: "#606060"))

                Spacer()
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 7)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(isSelected ? Color.white : isHovered ? Color.white.opacity(0.5) : Color.clear)
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
