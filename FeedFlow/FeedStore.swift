import SwiftUI
import Combine

struct Feed: Identifiable {
    let id = UUID()
    var title: String
    var url: String
    var articles: [Article] = []
}

struct Article: Identifiable {
    let id = UUID()
    var title: String
    var link: String
    var description: String
    var pubDate: String
    var isRead: Bool = false
}

class FeedStore: ObservableObject {
    @Published var feeds: [Feed] = [
        Feed(title: "iconfactory", url: "https://blog.iconfactory.com/feed/"),
        Feed(title: "r/macapps", url: "https://www.reddit.com/r/macapps.rss")
    ]
    @Published var selectedFeed: Feed? = nil
    @Published var selectedArticle: Article? = nil

    func fetchFeed(feed: Feed) {
        guard let url = URL(string: feed.url) else { return }
        var request = URLRequest(url: url)
        request.setValue("FeedFlow/1.0 (macOS; RSS Reader)", forHTTPHeaderField: "User-Agent")
        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data else { return }
            let parser = RSSParser(data: data)
            let articles = parser.parse()
            DispatchQueue.main.async {
                if let index = self.feeds.firstIndex(where: { $0.id == feed.id }) {
                    self.feeds[index].articles = articles
                }
            }
        }.resume()
    }

    func flowRandom() {
        let allArticles = feeds.flatMap { $0.articles }
        guard !allArticles.isEmpty else {
            feeds.forEach { fetchFeed(feed: $0) }
            return
        }
        selectedArticle = allArticles.randomElement()
    }
}

class RSSParser: NSObject, XMLParserDelegate {
    private let data: Data
    private var articles: [Article] = []
    private var currentElement = ""
    private var currentTitle = ""
    private var currentLink = ""
    private var currentDescription = ""
    private var currentPubDate = ""
    private var insideItem = false
    private var insideMediaGroup = false

    init(data: Data) { self.data = data }

    func parse() -> [Article] {
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
        return articles
    }

    func parser(_ parser: XMLParser, didStartElement element: String, namespaceURI: String?, qualifiedName: String?, attributes: [String: String] = [:]) {
        currentElement = element

        if element == "item" || element == "entry" {
            insideItem = true
            currentTitle = ""
            currentLink = ""
            currentDescription = ""
            currentPubDate = ""
        }

        // Atom format — YouTube usa <link href="..."/>
        if element == "link" && insideItem {
            if let href = attributes["href"], !href.isEmpty {
                currentLink = href
            }
        }

        // YouTube miniatura
        if element == "media:thumbnail" && insideItem {
            if let url = attributes["url"] {
                currentDescription = "<img src='\(url)' style='width:100%;border-radius:8px;'>"
            }
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard insideItem else { return }
        switch currentElement {
        case "title":
            currentTitle += string
        case "link":
            // Solo RSS clásico — Atom ya captura el href en didStartElement
            if currentLink.isEmpty {
                currentLink += string
            }
        case "description", "summary", "content", "content:encoded":
            currentDescription += string
        case "pubDate", "published", "updated":
            currentPubDate += string
        default:
            break
        }
    }

    func parser(_ parser: XMLParser, didEndElement element: String, namespaceURI: String?, qualifiedName: String?) {
        if element == "item" || element == "entry" {
            let title = currentTitle.trimmingCharacters(in: .whitespacesAndNewlines)
            let link = currentLink.trimmingCharacters(in: .whitespacesAndNewlines)
            let description = currentDescription.trimmingCharacters(in: .whitespacesAndNewlines)
            let pubDate = currentPubDate.trimmingCharacters(in: .whitespacesAndNewlines)

            if !title.isEmpty {
                articles.append(Article(
                    title: title,
                    link: link,
                    description: description,
                    pubDate: pubDate
                ))
            }
            insideItem = false
        }
    }
}
