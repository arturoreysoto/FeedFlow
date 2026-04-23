import SwiftUI

struct ArticleListView: View {
    @ObservedObject var store: FeedStore

    var body: some View {
        List(selection: Binding(
            get: { store.selectedArticle?.id },
            set: { id in store.selectedArticle = store.selectedFeed?.articles.first { $0.id == id } }
        )) {
            if let feed = store.selectedFeed {
                ForEach(feed.articles) { article in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(article.title)
                            .font(.system(size: 13, weight: .medium))
                            .lineLimit(2)
                        Text(article.pubDate)
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                    .tag(article.id)
                }
            } else {
                Text("Select a feed")
                    .foregroundStyle(.secondary)
            }
        }
        .listStyle(.plain)
    }
}
