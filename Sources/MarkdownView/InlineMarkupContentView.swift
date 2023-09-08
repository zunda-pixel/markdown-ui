//
//  InlineMarkupContentView.swift
//

import Algorithms
import MarkdownViewParser
import SwiftUI

public struct InlineMarkupContentView: InlineMarkupContentViewProtocol {
  public let content: InlineMarkupContent

  public init(content: InlineMarkupContent) {
    self.content = content
  }

  public var body: some View {
    switch content {
    case .text(let text):
      SwiftUI.Text(text)
    case .inlineAttributes(let attributes, let children):
      ForEach(children.indexed(), id: \.index) { _, child in
        InlineMarkupContentView(content: child)
      }
      .markdownAttributes(attributes: attributes)
    case .inlineHTML(let html):
      SwiftUI.Text(html)
    case .symbolLink(let destination):
      if let destination {
        SwiftUI.Text(destination)
          .background(.red)
      }
    case .strong(let children):
      ForEach(children.indexed(), id: \.index) { _, child in
        InlineMarkupContentView(content: child)
      }
      .bold()
    case .strikethrough(let children):
      ForEach(children.indexed(), id: \.index) { _, child in
        InlineMarkupContentView(content: child)
      }
      .strikethrough(pattern: .dash, color: .secondary)
    case .emphasis(let children):
      ForEach(children.indexed(), id: \.index) { _, child in
        InlineMarkupContentView(content: child)
      }
      .italic()
    case .inlineCode(let code):
      InlineCodeView(code: code)
    case .image(let title, let source):
      if let imageURL = source.map({ URL(string: $0) }),
         let imageURL {
        AsyncImage(url: imageURL) { image in
          image
            .resizable()
            .scaledToFit()
        } placeholder: {
          Text(title)
        }
      }
    case .softBreak:
      EmptyView() // TODO
    case .lineBreak:
      EmptyView() // TODO
    case .link(let destination, let children):
      if let destination,
         let url = URL(string: destination)
      {
        SwiftUI.Link(destination: url) {
          ForEach((children).indexed(), id: \.index) { _, content in
            InlineMarkupContentView(content: content)
          }
        }
      } else {
        ForEach((children).indexed(), id: \.index) { _, content in
          InlineMarkupContentView(content: content)
        }
      }
    case .unknown(let plainText):
      VStack(alignment: .leading, spacing: 10) {
        SwiftUI.Text("InlineMarkupContentView Unknown")
        SwiftUI.Text(plainText)
      }
    }
  }
}

extension View {
  func markdownAttributes(attributes: String) -> some View {
    self
  }
}