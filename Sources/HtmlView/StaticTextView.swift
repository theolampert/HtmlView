//
//  SwiftUIView.swift
//  HtmlView
//
//  Created by Theodore Lampert on 29.11.24.
//

import SwiftUI
import SwiftSoup

struct StaticTextView: UIViewRepresentable, Equatable {
    let element: Element
    let font: UIFont

    init(element: Element, font: UIFont) {
        self.element = element
        self.font = font
    }

    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UITextView, context: Context) -> CGSize? {
        guard let width = proposal.width else { return nil }
        let attributedText = try! StaticTextView.createLinkedAttributedText(from: element, font: font)
        let dimensions = attributedText.boundingRect(
            with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil)
        return .init(width: width, height: ceil(dimensions.height))

    }

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.font = font
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.isUserInteractionEnabled = true
        textView.isSelectable = true
        textView.backgroundColor = .clear
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = .zero
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.attributedText = try! StaticTextView.createLinkedAttributedText(from: element, font: font)
    }

    private static func createLinkedAttributedText(
        from element: Element,
        font: UIFont
    ) throws -> NSAttributedString {
        let fullText = try element.text()
        let attributedString = NSMutableAttributedString(
            string: fullText,
            attributes: [.font: font]
        )

        if element.children().size() > 0 {
            var lastIndex = fullText.startIndex

            for child in element.children() {
                let childText = try child.text()
                if let range = fullText.range(of: childText, range: lastIndex..<fullText.endIndex) {
                    let nsRange = NSRange(range, in: fullText)

                    if let href = try? child.attr("href"), let url = URL(string: href), url.host != nil, child.tagName() == "a" {
                        attributedString.addAttributes([
                            .link: url,
                            .underlineStyle: NSUnderlineStyle.single.rawValue
                        ], range: nsRange)
                    } else if child.tagName() == "strong" {
                        attributedString.addAttributes([
                            .font: font
                        ], range: nsRange)
                    }

                    lastIndex = range.upperBound
                }
            }
        }

        return attributedString
    }
}

#Preview {
    let html = """
    <p>Hello, world. <a href="https://paperback.ink"> Here's an inline link</a> <strong>Big bold text</strong> We need a little longer here to test out line breaking behaviour of this text. Or here maybe even we could. We need a little longer here to test out line breaking behaviour of this text.Or here maybe even we could. We need a little longer here to test out line breaking behaviour of this text. Or here maybe even we could. </p>
    """
    let paragraphElement = try! SwiftSoup.parse(html).select("p").first()!
    return ScrollView {
        return StaticTextView(element: paragraphElement, font: UIFont.systemFont(ofSize: 22))
    }
}
