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
        Feed(title: "iconfactory", url: "https://blog.iconfactory.com/feed/")
    ]
    @Published var selectedFeed: Feed? = nil
    @Published var selectedArticle: Article? = nil

    func fetchFeed(feed: Feed) {
        guard let url = URL(string: feed.url) else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
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
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard insideItem else { return }
        switch currentElement {
        case "title": currentTitle += string
        case "link": currentLink += string
        case "description", "summary": currentDescription += string
        case "pubDate", "published": currentPubDate += string
        default: break
        }
    }

    func parser(_ parser: XMLParser, didEndElement element: String, namespaceURI: String?, qualifiedName: String?) {
        if element == "item" || element == "entry" {
            articles.append(Article(
                title: currentTitle.trimmingCharacters(in: .whitespacesAndNewlines),
                link: currentLink.trimmingCharacters(in: .whitespacesAndNewlines),
                description: currentDescription.trimmingCharacters(in: .whitespacesAndNewlines),
                pubDate: currentPubDate.trimmingCharacters(in: .whitespacesAndNewlines)
            ))
            insideItem = false
        }
    }
}
