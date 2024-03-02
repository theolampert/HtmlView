import Kingfisher
import SwiftSoup
import SwiftUI

extension Element {
    var hasSingleImageChild: Bool {
        self.children().count == 1 && self.children().first()?.tagName() == "img"
    }
}

public struct HtmlElement: View, Equatable {
    let element: SwiftSoup.Element
    let blockSpacing: CGFloat

    @ViewBuilder
    func renderFigure(element: SwiftSoup.Element) -> some View {
        VStack(alignment: .leading) {
            if let img = try? element.getElementsByTag("img").first() {
                HtmlImageView(element: img)
                if let figCaption = try? element.getElementsByTag("figcaption").first(),
                   let text = try? figCaption.text() {
                    Text(text)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    @ViewBuilder
    func renderLink(element: SwiftSoup.Element) -> some View {
        if let href = try? element.attr("href"), let url = URL(string: href) {
            Link(destination: url, label: {
                Text(element.ownText())
                    .underline()
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.blue)
            })
        }
    }

    func createLinkedText(from element: Element) throws -> Text {
        let fullText = try element.text()
        
        var resultText = Text("")
        
        if element.children().size() > 0 {
            var lastIndex = fullText.startIndex
            
            for child in element.children() {
                let childText = try child.text()
                if let range = fullText.range(of: childText, range: lastIndex..<fullText.endIndex) {
                    let beforeLink = String(fullText[lastIndex..<range.lowerBound])
                    if !beforeLink.isEmpty {
                        resultText = resultText + Text(beforeLink)
                    }
                    
                    if let href = try? child.attr("href"), let url = URL(string: href), child.tagName() == "a" {
                        let linkText = Text(childText) {
                            $0.link = url
                            $0.underlineStyle = .single
                        }
                        resultText = resultText + linkText
                    } else {
                        resultText = resultText + Text(childText) {
                            if child.tagName() == "strong" {
                                $0.font = .body.bold()
                            }
                        }
                    }
                    
                    lastIndex = range.upperBound
                }
            }
            
            let remainingText = String(fullText[lastIndex..<fullText.endIndex])
            if !remainingText.isEmpty {
                resultText = resultText + Text(remainingText)
            }
        } else {
            resultText = Text(fullText)
        }
        
        return resultText
    }
    
    @ViewBuilder
    func optionalTextWithInlineLinks(_ elem: Element) -> some View {
        try? createLinkedText(from: elem)
            .textSelection(.enabled)
    }
    
    public var body: some View {
        switch true {
        case element.tagName() == "p" && !element.hasSingleImageChild:
            optionalTextWithInlineLinks(element)
        case element.tagName() == "small":
            optionalTextWithInlineLinks(element)
                .font(.caption)
                .foregroundColor(.secondary)
        case element.tagName() == "span" && element.hasText():
            optionalTextWithInlineLinks(element)
                .font(.caption)
                .foregroundColor(.secondary)
        case element.tagName() == "h1":
            optionalTextWithInlineLinks(element)
                .font(.title2)
                .bold()
        case element.tagName() == "h2":
            optionalTextWithInlineLinks(element)
                .font(.title3)
                .bold()
        case ["h3", "h4", "h5", "h6", "strong"].contains(element.tagName()):
            optionalTextWithInlineLinks(element)
                .bold()
        case ["blockquote", "em", "italic", "i"].contains(element.tagName()):
            optionalTextWithInlineLinks(element)
                .italic()
        case element.tagName() == "img":
            HtmlImageView(element: element)
                .equatable()
        case element.tagName() == "figure":
            renderFigure(element: element)
        case element.tagName() == "a":
            renderLink(element: element)
        case element.tagName() == "hr":
            Divider()
        case element.tagName() == "ul":
            VStack(alignment: .leading, spacing: 8) {
                ForEach(element.children(), id: \.self) { elem in
                    HStack(alignment: .firstTextBaseline) {
                        Text("•")
                        optionalTextWithInlineLinks(elem)
                    }
                }
            }
        case element.tagName() == "ol":
            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(element.children().enumerated()), id: \.0) { idx, elem in
                    HStack(alignment: .firstTextBaseline) {
                        Text("\(idx + 1).")
                        optionalTextWithInlineLinks(elem)
                    }
                }
            }
        case element.tagName() == "table":
            HtmlTableView(element: element)
        case element.tagName() == "br":
            Spacer()
        case ["code", "pre"].contains(element.tagName()):
            HtmlCodeView(element: element)
                .equatable()
        default:
            VStack(alignment: .leading, spacing: blockSpacing) {
                ForEach(element.children(), id: \.self) { nextElement in
                    HtmlElement(element: nextElement, blockSpacing: blockSpacing)
                        .equatable()
                }
            }
//            #if DEBUG
//            Text(element.description)
//                .foregroundStyle(.red)
//            #endif
        }
    }
}

public struct HtmlView: View, Equatable {
    public init(html: String, blockSpacing: CGFloat = 24) {
        self.html = html
        self.blockSpacing = blockSpacing
    }
    
    public let html: String
    public let blockSpacing: CGFloat

    public var body: some View {
        if let content = try? SwiftSoup.parse(html), let elements = content.body()?.children() {
            VStack(alignment: .leading, spacing: blockSpacing) {
                ForEach(elements, id: \.self) { element in
                    HtmlElement(
                        element: element,
                        blockSpacing: blockSpacing
                    ).equatable()
                }
            }
            .textSelection(.enabled)
            .frame(minWidth: 0, maxWidth: .infinity)
        }
    }
}

struct HtmlRenderer_Previews: PreviewProvider {
    static var previews: some View {
        let html = """
        <h1>👋 HtmlView</h1>
        <h2>Render HTML into SwiftUI views</h2>
        <p>HtmlView is an experimental package for rendering a subset of HTML to native SwiftUI views.</p>
        <p>HtmlView makes use of <a href="https://github.com/scinfu/SwiftSoup">SwiftSoup</a> to build a tree of HTML elements and render them into roughly equivalent SwiftUI views.</p>
        <small>Auther Name: <a href="https://www.theo.sh">Theo Lampert</a></small>
        <img src="https://media.urbit.org/site/posts/essays/pre-03.jpg"/>
        <ul>
            <li>List item one</l1>
            <li>List item two</l1>
            <li>List item three</l1>
            <li>List item four</l1>
        </ul>
        <ol>
            <li>Hello one</l1>
            <li>Hello two</l1>
            <li>Hello three</l1>
            <li>Hello four</l1>
        </ol>
        <p><span>Hello</span></p>
        <span>Help</span>
        <code>
        HtmlElement(element: element).equatable()
        </code>
        """
        return ScrollView {
            HtmlView(html: html).padding()
        }
    }
}

extension Text {
    init(_ string: String, configure: ((inout AttributedString) -> Void)) {
        var attributedString = AttributedString(string) /// create an `AttributedString`
        configure(&attributedString) /// configure using the closure
        self.init(attributedString) /// initialize a `Text`
    }
}
