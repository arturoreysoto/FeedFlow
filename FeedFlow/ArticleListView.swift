import SwiftUI

struct ArticleListView: View {
    @ObservedObject var store: FeedStore

    var body: some View {
        VStack(spacing: 0) {
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
                }
                .listStyle(.plain)
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "tray")
                        .font(.system(size: 32))
                        .foregroundStyle(.secondary)
                    Text("No articles")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

struct ArticleRow: View {
    let article: Article

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(article.title)
                .font(.system(size: 13, weight: .medium))
                .lineLimit(2)
            Text(article.pubDate)
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}
