import SwiftUI

struct ArticleListView: View {
    @ObservedObject var store: FeedStore

    var body: some View {
        VStack(spacing: 0) {
            if store.isLoading {
                VStack(spacing: 12) {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaleEffect(0.8)
                    Text("Loading...")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "#999999"))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(hex: "#FFFDF8"))
            } else if let feed = store.selectedFeed, !feed.articles.isEmpty {
                List {
                    ForEach(feed.articles) { article in
                        ArticleRow(article: article, isSelected: store.selectedArticle?.id == article.id)
                            .onTapGesture {
                                store.selectedArticle = article
                            }
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                    }
                }
                .listStyle(.plain)
                .background(Color(hex: "#FFFDF8"))
                .scrollContentBackground(.hidden)
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
                .background(Color(hex: "#FFFDF8"))
            }
        }
        .background(Color(hex: "#FFFDF8"))
    }
}

struct ArticleRow: View {
    let article: Article
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 3) {
                VStack(alignment: .leading, spacing: 0) {
                    Text(article.title)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(hex: "#1A1A1A"))
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(article.pubDate.formattedDate)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Color(hex: "#999999"))
                        .padding(.top, 2)

                    if !article.cleanDescription.isEmpty {
                        Text(article.cleanDescription)
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(Color(hex: "#606060"))
                            .lineLimit(3)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, 3)
                    }
                }
                Spacer()
            }

            Divider()
                .background(Color(hex: "#E8E8E5"))
                .padding(.top, 14)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 10)
        .padding(.horizontal, 30)
        .background(isSelected ? Color(hex: "#ECEAE4") : Color.clear)
    }
}

// MARK: - Helpers
extension String {
    var formattedDate: String {
        let formatters: [DateFormatter] = {
            let f1 = DateFormatter()
            f1.locale = Locale(identifier: "en_US_POSIX")
            f1.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"

            let f2 = DateFormatter()
            f2.locale = Locale(identifier: "en_US_POSIX")
            f2.dateFormat = "EEE, dd MMM yyyy HH:mm:ss z"

            let f3 = DateFormatter()
            f3.locale = Locale(identifier: "en_US_POSIX")
            f3.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            return [f1, f2, f3]
        }()

        for formatter in formatters {
            if let date = formatter.date(from: self) {
                let out = DateFormatter()
                out.dateFormat = "EEEE, dd MMM yyyy · HH:mm"
                return out.string(from: date)
            }
        }
        return self
    }
}
