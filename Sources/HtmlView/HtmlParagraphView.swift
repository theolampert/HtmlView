import SwiftUI
import SwiftSoup

public struct HtmlParagraphView: View, Equatable {
    let element: Element
    
    private func createLinkedText(from element: Element) throws -> Text {
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
                    if let href = try? child.attr("href"), let url = URL(string: href), url.host != nil, child.tagName() == "a" {
                        let linkText = Text(childText) {
                            $0.link = url
                            $0.underlineStyle = .single
                        }
                        resultText = resultText + linkText
                    } else if child.tagName() == "strong" {
                        resultText = resultText + Text("**\(childText)**")
                    } else {
                        resultText = resultText + Text(childText)
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
    
    public var body: some View {
        try? createLinkedText(from: element)
            .textSelection(.enabled)
    }
}

extension Text {
    init(_ string: String, configure: ((inout AttributedString) -> Void)) {
        var attributedString = AttributedString(string) /// create an `AttributedString`
        configure(&attributedString) /// configure using the closure
        self.init(attributedString) /// initialize a `Text`
    }
}

#Preview {
    let html = """
    <p>
    Hello, world. <a href="https://paperback.ink"> Here's an inline link</a>
    <strong>Big bold text</strong>
    </p>
    """
    let paragraphElement = try! SwiftSoup.parse(html).select("p").first()!
    return HtmlParagraphView(
        element: paragraphElement
    )
    .font(.system(size: 22))
    .padding()
}