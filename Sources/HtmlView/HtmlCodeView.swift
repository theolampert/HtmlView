import SwiftUI
import SwiftSoup

public struct HtmlCodeView: View, Equatable {
    let element: Element
    
    public var body: some View {
        if let text = try? element.text().replacingOccurrences(of: "\\n", with: "\n") {
            GroupBox(content: {
                ScrollView(.horizontal) {
                    Text(text)
                        .font(.system(size: 12, design: .monospaced))
                }
            }, label: {})
        }
    }
}

#Preview {
    let html = """
    <code>
    VStack {
      HtmlCodeView(element: imgElem)
    }
    </code>
    """
    let imgElem = try! SwiftSoup.parse(html).select("code").first()!
    return HtmlCodeView(
        element: imgElem
    )
    .equatable()
    .padding()
}
