//
//  DoxygenReturnsView.swift
//

import Markdown
import SwiftUI

public struct DoxygenReturnsView: View {
  public let children: [MarkupContent]

  public init(
    children: [MarkupContent]
  ) {
    self.children = children
  }

  public var body: some View {
    ForEach(children, id: \.self) { child in
      MarkupContentView(content: child)
    }
  }
}

#Preview {
  let source = """
    \\returns A freshly-created object1.
    \\returns A freshly-created object2.
    """

  let document = Document(
    parsing: source,
    options: [.parseBlockDirectives, .parseMinimalDoxygen]
  )

  return ScrollView {
    LazyVStack(alignment: .leading) {
      MarkdownView(document: document)
    }
  }
}
