import SwiftUI

struct ArticleDetailView: View {
    @ObservedObject var store: FeedStore

    var body: some View {
        Group {
            if let article = store.selectedArticle {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(article.title)
                            .font(.system(size: 22, weight: .bold))
                        
                        Text(article.pubDate)
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                        
                        Divider()
                        
                        Text(article.description)
                            .font(.system(size: 14))
                            .lineSpacing(6)
                        
                        Spacer()
                        
                        Link("Read full article →", destination: URL(string: article.link) ?? URL(string: "https://google.com")!)
                            .font(.system(size: 13, weight: .medium))
                    }
                    .padding(24)
                }
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "newspaper")
                        .font(.system(size: 40))
                        .foregroundStyle(.secondary)
                    Text("Select an article")
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
