import SwiftUI
import Nuke
import NukeUI
import SwiftSoup

public struct HtmlImageView: View, Equatable {
    let element: Element
    
    public var body: some View {
        if let src = try? element.attr("src"), !src.isEmpty, let url = URL(string: src) {
            LazyImage(url: url) { state in
                if let image = state.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    Rectangle()
                        .foregroundColor(Color.secondary.opacity(0.2))
                        .aspectRatio(contentMode: .fit)
                }
            }
            .processors([
                ImageProcessors.Resize(
                    size: CGSize(
                        width: UIScreen.main.bounds.width * UIScreen.main.scale,
                        height: UIScreen.main.bounds.height * UIScreen.main.scale
                    ),
                    contentMode: .aspectFit
                )
            ])
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
