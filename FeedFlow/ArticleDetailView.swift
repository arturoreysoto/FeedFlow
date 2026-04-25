import SwiftUI
import WebKit

struct ArticleDetailView: View {
    @ObservedObject var store: FeedStore

    var body: some View {
        Group {
            if let article = store.selectedArticle {
                ReaderView(article: article)
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "newspaper")
                        .font(.system(size: 40))
                        .foregroundStyle(.secondary)
                    Text("Select an article")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

struct ReaderView: NSViewRepresentable {
    let article: Article

    func makeNSView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.userContentController.add(context.coordinator, name: "readerContent")
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        context.coordinator.article = article
        context.coordinator.webView = webView
        context.coordinator.loadArticle()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var article: Article?
        var webView: WKWebView?

        func loadArticle() {
            guard let article = article,
                  let url = URL(string: article.link) else {
                showRSSContent()
                return
            }

            var request = URLRequest(url: url)
            request.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36", forHTTPHeaderField: "User-Agent")

            URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data,
                      let html = String(data: data, encoding: .utf8) ?? String(data: data, encoding: .isoLatin1) else {
                    DispatchQueue.main.async { self.showRSSContent() }
                    return
                }
                DispatchQueue.main.async {
                    self.processWithReadability(html: html, url: url)
                }
            }.resume()
        }

        func showRSSContent() {
            guard let article = article else { return }
            let content = article.description.isEmpty ? "<p>No content available.</p>" : article.description
            let readerHTML = buildReaderHTML(title: article.title, byline: article.pubDate, content: content)
            DispatchQueue.main.async {
                self.webView?.loadHTMLString(readerHTML, baseURL: nil)
            }
        }

        func processWithReadability(html: String, url: URL) {
            guard let webView = webView,
                  let readabilityPath = Bundle.main.path(forResource: "Readability", ofType: "js"),
                  let readabilityJS = try? String(contentsOfFile: readabilityPath, encoding: .utf8) else {
                showRSSContent()
                return
            }

            let escapedHTML = html
                .replacingOccurrences(of: "\\", with: "\\\\")
                .replacingOccurrences(of: "`", with: "\\`")
                .replacingOccurrences(of: "$", with: "\\$")

            let js = """
            \(readabilityJS)

            (function() {
                var parser = new DOMParser();
                var doc = parser.parseFromString(`\(escapedHTML)`, 'text/html');
                var reader = new Readability(doc);
                var article = reader.parse();

                if (article && article.content && article.content.length > 100) {
                    window.webkit.messageHandlers.readerContent.postMessage({
                        title: article.title || '',
                        content: article.content || '',
                        byline: article.byline || '',
                        success: 'true'
                    });
                } else {
                    window.webkit.messageHandlers.readerContent.postMessage({
                        title: '',
                        content: '',
                        byline: '',
                        success: 'false'
                    });
                }
            })();
            """

            webView.loadHTMLString("<html><body></body></html>", baseURL: url)
            webView.evaluateJavaScript(js) { _, error in
                if let error = error {
                    print("Readability error: \(error)")
                    self.showRSSContent()
                }
            }
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            guard let body = message.body as? [String: String] else { return }
            let success = body["success"] ?? "false"

            if success == "true" {
                let title = body["title"] ?? ""
                let content = body["content"] ?? ""
                let byline = body["byline"] ?? ""
                let readerHTML = buildReaderHTML(title: title, byline: byline, content: content)
                DispatchQueue.main.async {
                    self.webView?.loadHTMLString(readerHTML, baseURL: nil)
                }
            } else {
                showRSSContent()
            }
        }

        func buildReaderHTML(title: String, byline: String, content: String) -> String {
            return """
            <!DOCTYPE html>
            <html>
            <head>
            <meta charset="UTF-8">
            <style>
                * { box-sizing: border-box; margin: 0; padding: 0; }
                body {
                    font-family: -apple-system, Georgia, serif;
                    font-size: 17px;
                    line-height: 1.75;
                    color: #1A1A1A;
                    background: #FFFFFF;
                    max-width: 680px;
                    margin: 0 auto;
                    padding: 40px 24px 80px 24px;
                }
                .article-title { font-size: 26px; font-weight: 700; line-height: 1.3; margin-bottom: 8px; }
                .article-byline { font-size: 13px; color: #999999; margin-bottom: 24px; }
                .article-divider { border: none; border-top: 1px solid #E9E9E7; margin-bottom: 24px; }
                h1 { font-size: 24px; font-weight: 700; margin: 24px 0 12px; }
                h2 { font-size: 20px; font-weight: 600; margin: 20px 0 10px; }
                h3 { font-size: 17px; font-weight: 600; margin: 16px 0 8px; }
                p { margin-bottom: 18px; color: #333333; }
                a { color: #FF736A; text-decoration: none; }
                img { max-width: 100%; border-radius: 8px; margin: 20px 0; display: block; }
                blockquote { border-left: 3px solid #FF736A; padding-left: 16px; margin: 20px 0; color: #666666; font-style: italic; }
                code { background: #F5F5F5; padding: 2px 6px; border-radius: 4px; font-family: 'SF Mono', monospace; font-size: 14px; }
                pre { background: #F5F5F5; padding: 16px; border-radius: 8px; overflow-x: auto; margin: 20px 0; }
                ul, ol { margin: 16px 0; padding-left: 24px; }
                li { margin-bottom: 6px; }
                figure { margin: 20px 0; }
                figcaption { font-size: 13px; color: #999999; margin-top: 8px; }
            </style>
            </head>
            <body>
                \(title.isEmpty ? "" : "<h1 class='article-title'>\(title)</h1>")
                \(byline.isEmpty ? "" : "<p class='article-byline'>\(byline)</p>")
                \(title.isEmpty ? "" : "<hr class='article-divider'>")
                \(content)
            </body>
            </html>
            """
        }
    }
}
