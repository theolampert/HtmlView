import SwiftUI
import Kingfisher
import SwiftSoup

public struct HtmlImageView: View, Equatable {
    let element: Element
    
    public var body: some View {
        if let src = try? element.attr("src"), !src.isEmpty, let url = URL(string: src) {
            KFImage(url)
                .setProcessor(DownsamplingImageProcessor(
                    size: CGSize(
                        width: UIScreen.main.bounds.width,
                        height: UIScreen.main.bounds.height
                    ))
                )
                .scaleFactor(UIScreen.main.scale)
                .placeholder {
                    Rectangle()
                        .foregroundColor(Color.secondary.opacity(0.2))
                        .aspectRatio(contentMode: .fit)
                }
                .antialiased(true)
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
    }
}

#Preview {
    let html = """
    <img src="https://media.urbit.org/site/posts/essays/pre-03.jpg"/>
    """
    let imgElem = try! SwiftSoup.parse(html).select("img").first()!
    return HtmlImageView(
        element: imgElem
    )
    .equatable()
    .padding()
}
