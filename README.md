#### Render a simple subset of HTML as SwiftUI views. 


```swift
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
ScrollView {
    HtmlView(html: html).padding()
}
```
