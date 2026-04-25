import SwiftUI

struct ArticleListView: View {
    @ObservedObject var store: FeedStore

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(store.selectedFeed?.title ?? "Inbox")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color(hex: "#606060"))
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            Divider()
                .background(Color(hex: "#E9E9E7"))

            if let feed = store.selectedFeed, !feed.articles.isEmpty {
                List(selection: Binding(
                    get: { store.selectedArticle?.id },
                    set: { id in
                        DispatchQueue.main.async {
                            store.selectedArticle = store.selectedFeed?.articles.first { $0.id == id }
                        }
                    }
                )) {
                    ForEach(feed.articles) { article in
                        ArticleRow(article: article)
                            .tag(article.id)
                    }
                    .listRowBackground(Color.white)
                    .listRowSeparator(.visible)
                    .listRowSeparatorTint(Color(hex: "#E9E9E7"))
                }
                .listStyle(.plain)
                .background(Color.white)
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "tray")
                        .font(.system(size: 32))
                        .foregroundStyle(Color(hex: "#C0C0C0"))
                    Text("No articles")
                        .font(.system(size: 13))
                        .foregroundStyle(Color(hex: "#C0C0C0"))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
            }
        }
        .background(Color.white)
    }
}

struct ArticleRow: View {
    let article: Article

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(article.title)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color(hex: "#1A1A1A"))
                .lineLimit(2)
            Text(article.pubDate)
                .font(.system(size: 11))
                .foregroundStyle(Color(hex: "#999999"))
        }
        .padding(.vertical, 6)
    }
}
