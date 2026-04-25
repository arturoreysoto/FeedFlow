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
    var cleanDescription: String = ""
    var pubDate: String
    var isRead: Bool = false
}

class FeedStore: ObservableObject {
    @Published var feeds: [Feed] = []
    @Published var selectedFeed: Feed? = nil
    @Published var selectedArticle: Article? = nil
    @Published var isLoading: Bool = false

    func fetchFeed(feed: Feed) {
        guard let url = URL(string: feed.url) else { return }
        DispatchQueue.main.async { self.isLoading = true }
        var request = URLRequest(url: url)
        request.setValue("FeedFlow/1.0 (macOS; RSS Reader)", forHTTPHeaderField: "User-Agent")
        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data else {
                DispatchQueue.main.async { self.isLoading = false }
                return
            }
            DispatchQueue.global(qos: .userInitiated).async {
                let parser = RSSParser(data: data)
                let articles = parser.parse()
                DispatchQueue.main.async {
                    if let index = self.feeds.firstIndex(where: { $0.id == feed.id }) {
                        self.feeds[index].articles = articles
                        if self.selectedFeed?.id == feed.id {
                            self.selectedFeed = self.feeds[index]
                        }
                    }
                    self.isLoading = false
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
    private var currentContent = ""
    private var currentPubDate = ""
    private var currentImageURL = ""
    private var channelImageURL = ""
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
            currentContent = ""
            currentPubDate = ""
            currentImageURL = ""
        }

        if element == "link" && insideItem {
            if let href = attributes["href"], !href.isEmpty {
                currentLink = href
            }
        }

        if element == "enclosure" && insideItem {
            if let url = attributes["url"],
               let type = attributes["type"],
               type.hasPrefix("image") {
                currentImageURL = url
            }
        }

        if (element == "media:content" || element == "media:thumbnail") && insideItem {
            if let url = attributes["url"] {
                currentImageURL = url
            }
        }

        if element == "itunes:image" && insideItem {
            if let href = attributes["href"], !href.isEmpty {
                currentImageURL = href
            }
        }

        if element == "itunes:image" && !insideItem {
            if let href = attributes["href"], !href.isEmpty {
                channelImageURL = href
            }
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard insideItem else { return }
        switch currentElement {
        case "title":
            currentTitle += string
        case "link":
            if currentLink.isEmpty {
                currentLink += string
            }
        case "description", "summary":
            if currentContent.isEmpty {
                currentDescription += string
            }
        case "content:encoded":
            currentContent += string
        case "content":
            if currentContent.isEmpty {
                currentContent += string
            }
        case "pubDate", "published", "updated":
            currentPubDate += string
        default:
            break
        }
    }

    func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
        guard insideItem else { return }
        guard let string = String(data: CDATABlock, encoding: .utf8) else { return }
        switch currentElement {
        case "content:encoded":
            currentContent += string
        case "description", "summary":
            if currentContent.isEmpty {
                currentDescription += string
            }
        case "content":
            if currentContent.isEmpty {
                currentContent += string
            }
        default:
            break
        }
    }

    func parser(_ parser: XMLParser, didEndElement element: String, namespaceURI: String?, qualifiedName: String?) {
        if element == "item" || element == "entry" {
            let title = currentTitle.trimmingCharacters(in: .whitespacesAndNewlines)
            let link = currentLink.trimmingCharacters(in: .whitespacesAndNewlines)
            let pubDate = currentPubDate.trimmingCharacters(in: .whitespacesAndNewlines)

            let rawContent = currentContent.isEmpty ? currentDescription : currentContent
            var finalContent = rawContent.trimmingCharacters(in: .whitespacesAndNewlines)

            let imageToUse = currentImageURL.isEmpty ? channelImageURL : currentImageURL
            if !imageToUse.isEmpty && !finalContent.contains(imageToUse) {
                finalContent = "<img src='\(imageToUse)' loading='lazy' style='width:50%;border-radius:12px;margin-bottom:24px;'>" + finalContent
            }

            // Texto limpio para la lista — sin NSAttributedString en el hilo principal
            let cleanDescription = finalContent
                .replacingOccurrences(of: "<[^>]+>", with: " ", options: .regularExpression)
                .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
                .trimmingCharacters(in: .whitespacesAndNewlines)

            if !title.isEmpty {
                articles.append(Article(
                    title: title,
                    link: link,
                    description: finalContent,
                    cleanDescription: cleanDescription,
                    pubDate: pubDate
                ))
            }
            insideItem = false
        }
    }
}
