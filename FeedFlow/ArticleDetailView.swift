import SwiftUI
import WebKit

class WebViewStore {
    let webView: WKWebView

    init() {
        let config = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: config)
        webView.setValue(false, forKey: "drawsBackground")
    }

    func load(article: Article) {
        let html = buildReaderHTML(article: article)
        webView.loadHTMLString(html, baseURL: nil)
    }

    func buildReaderHTML(article: Article) -> String {
        let content = article.description.isEmpty
            ? "<p>No content available.</p>"
            : article.description

        return """
        <!DOCTYPE html>
        <html>
        <head>
        <meta charset="UTF-8">
        <style>
            * { box-sizing: border-box; margin: 0; padding: 0; }
            body {
                font-family: -apple-system, BlinkMacSystemFont, 'Helvetica Neue', sans-serif;
                font-size: 18px;
                line-height: 1.7;
                color: #1A1A1A;
                background: #FFFDF8;
                padding: 48px 48px 100px 48px;
                max-width: 660px;
                margin: 0 auto;
            }
            .article-title {
                font-size: 36px;
                font-weight: 700;
                line-height: 1.2;
                color: #1A1A1A;
                margin-bottom: 32px;
                letter-spacing: -0.5px;
            }
            .article-divider {
                border: none;
                border-top: 1px solid #E8E8E5;
                margin: 0 0 32px 0;
            }
            p {
                margin-bottom: 24px;
                color: #1A1A1A;
                line-height: 1.7;
                font-size: 18px;
            }
            h1 { font-size: 28px; font-weight: 700; margin: 36px 0 14px; color: #1A1A1A; letter-spacing: -0.3px; }
            h2 { font-size: 22px; font-weight: 600; margin: 30px 0 12px; color: #1A1A1A; }
            h3 { font-size: 18px; font-weight: 600; margin: 24px 0 10px; color: #1A1A1A; }
            a { color: #FF736A; text-decoration: none; }
            a:hover { text-decoration: underline; }
            img {
                max-width: 100%;
                border-radius: 11px;
                margin: 28px 0;
                display: block;
                content-visibility: auto;
            }
            blockquote {
                border-left: 3px solid #FF736A;
                padding: 4px 0 4px 20px;
                margin: 28px 0;
                color: #606060;
                font-style: italic;
            }
            code {
                background: #F0F0EE;
                padding: 2px 6px;
                border-radius: 4px;
                font-family: 'SF Mono', 'Menlo', monospace;
                font-size: 15px;
            }
            pre {
                background: #F0F0EE;
                padding: 20px;
                border-radius: 10px;
                overflow-x: auto;
                margin: 28px 0;
                line-height: 1.6;
            }
            ul, ol { margin: 18px 0 24px 0; padding-left: 28px; }
            li { margin-bottom: 10px; line-height: 1.7; }
            figure { margin: 28px 0; }
            figcaption { font-size: 13px; color: #999999; margin-top: 10px; text-align: center; }
        </style>
        </head>
        <body>
            <h1 class='article-title'>\(article.title)</h1>
            <hr class='article-divider'>
            \(content)
        </body>
        </html>
        """
    }
}

struct ArticleDetailView: View {
    @ObservedObject var store: FeedStore
    @State private var webViewStore = WebViewStore()

    var body: some View {
        Group {
            if let article = store.selectedArticle {
                ReaderWebView(webViewStore: webViewStore, article: article)
                    .background(Color(hex: "#FFFDF8"))
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
                .background(Color(hex: "#FFFDF8"))
            }
        }
    }
}

struct ReaderWebView: NSViewRepresentable {
    let webViewStore: WebViewStore
    let article: Article

    func makeNSView(context: Context) -> WKWebView {
        let webView = webViewStore.webView
        webView.navigationDelegate = context.coordinator
        return webView
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {
        guard context.coordinator.currentArticleID != article.id else { return }
        context.coordinator.currentArticleID = article.id
        webViewStore.load(article: article)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var currentArticleID: UUID?

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if navigationAction.navigationType == .linkActivated,
               let url = navigationAction.request.url {
                NSWorkspace.shared.open(url)
                decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
            }
        }
    }
}
