//
//  MarkupContentView.swift
//

import SwiftUI
import Algorithms

struct MarkupContentView: View {
  let content: MarkupContent
  let listDepth: Int
  
  var unorderedMark: [Int: String] = [
    0: "•",
    1: "◦",
    2: "▫︎"
  ]
  
  var fonts: [Int: Font] = [
    1: .title,
    2: .title2,
    3: .title3,
  ]
  
  var body: some View {
    switch content {
    case .text(let text):
      SwiftUI.Text(text)
    case .htmlBlock(let text):
      SwiftUI.Text(text)
    case .codeBlock(let language, let sourceCode):
      VStack(alignment: .leading, spacing: 10) {
        if let language {
          Text(language)
        }
        Text(sourceCode)
      }
    case .link(let destination, let children):
      if let destination,
         let url = URL(string: destination) {
        SwiftUI.Link(destination: url) {
          ForEach(children.indexed(), id: \.index) { _, content in
            InlineMarkupContentView(content: content)
          }
        }
      } else {
        ForEach(children.indexed(), id: \.index) { _, content in
          InlineMarkupContentView(content: content)
        }
      }
    case .heading(let level, let children):
      HStack(alignment: .center, spacing: 10) {
        ForEach(children.indexed(), id: \.index) { _, content in
          InlineMarkupContentView(content: content)
        }
      }
      .ifLet(fonts[level]) { view, font in
        view.font(font)
      }
    case .paragraph(let children):
      VStack(alignment: .center, spacing: 10) {
        ForEach(children.indexed(), id: \.index) { _, content in
          InlineMarkupContentView(content: content)
        }
      }
      
    case .blockQuote(let blockChildren):
      HStack(alignment: .top, spacing: 10) {
        Rectangle()
          .fill(.secondary)
          .frame(maxWidth: 3)
        VStack(alignment: .leading, spacing: 10) {
          ForEach(blockChildren.indexed(), id: \.index) { _, blockChild in
            ForEach(blockChild.indexed(), id: \.index) { _, children in
              MarkupContentView(content: children, listDepth: listDepth)
            }
          }
        }
      }
      .foregroundStyle(.secondary)
      // TODO 縦棒が縦に広がりすぎてしまうので、fixedSizeで最小になるようにしている。
      // これが正しいのかはわからない
      .fixedSize(horizontal: true, vertical: true)
    case .orderedList(let items):
      VStack(alignment: .leading, spacing: 10) {
        ForEach(items.indexed(), id: \.index) { index, item in
          HStack(alignment: .center, spacing: 5) {
            Text("\(index + 1).")
            ForEach(item.children.indexed(), id: \.index) { _, child in
              MarkupContentView(content: child, listDepth: listDepth)
            }
          }
        }
      }
    case .unorderedList(let items):
      VStack(alignment: .leading, spacing: 10) {
        ForEach(items.indexed(), id: \.index) { _, item in
          VStack(alignment: .leading, spacing: 10) {
            ForEach(item.children.indexed(), id: \.index) { _, child in
              HStack(alignment: .center, spacing: 10) {
                if case .unorderedList(_) = child {
                  Spacer().frame(width: 10)
                } else {
                  if let checkbox = item.checkbox {
                    Image(systemName: checkbox == .checked ? "checkmark.square" : "square")
                  } else {
                    Text(unorderedMark[listDepth] ?? unorderedMark[unorderedMark.count - 1]!)
                  }
                }
                
                MarkupContentView(content: child, listDepth: listDepth + 1)
              }
            }
          }
        }
      }
    case .table(let headItems, let bodyItems):
      Grid {
        GridRow {
          ForEach(headItems.indexed(), id: \.index) { _, item in
            InlineMarkupContentView(content: item)
          }
        }
        
        Divider()
        
        ForEach(bodyItems.indexed(), id: \.index) { _, items in
          GridRow {
            ForEach(items.indexed(), id: \.index) { _, items in
              VStack {
                ForEach(items.indexed(), id: \.index) { _, item in
                  InlineMarkupContentView(content: item)
                }
              }
            }
          }
          Divider()
        }
      }

    case .softBreak:
      EmptyView()// TODO
    }
  }
}


#Preview {
  let items: [MarkupContent] = [
    .heading(level: 1, children: [.text(text: "Title1")]),
    .heading(level: 2, children: [.text(text: "Title2")]),
    .heading(level: 3, children: [.text(text: "Title3")]),
    .heading(level: 4, children: [.text(text: "Title4")]),
    .text(text: "Title5"),
    .codeBlock(language: "swift", sourceCode: """
import Foundation
print("Hello")
"""),
    .orderedList(items: [
      .init(
        checkbox: nil,
        children: [
          .text(text: "Item1")
        ]
      ),
      .init(
        checkbox: nil,
        children: [
          .text(text: "Item2")
        ]
      ),
      .init(
        checkbox:  nil,
        children: [
          .text(text: "Item3")
        ]
      ),
    ]),
    .unorderedList(items: [
      .init(
        checkbox: nil,
        children: [
          .text(text: "Item1")
        ]
      ),
      .init(
        checkbox: .checked,
        children: [
          .text(text: "Item2")
        ]
      ),
      .init(
        checkbox: .checked,
        children: [
          .text(text: "Item3")
        ]
      ),
    ])
  ]
  
  return ScrollView {
    LazyVStack(alignment: .leading, spacing: 10) {
      ForEach(items.indexed(), id: \.index) { _, item in
        MarkupContentView(content: item, listDepth: 0)
        Divider()
      }
    }
  }
    .frame(maxWidth: 500, maxHeight: 500)
}

private extension View {
  @ViewBuilder
  func ifLet<Value, Content: View>(
    _ value: Value?,
    @ViewBuilder content: (Self, Value) -> Content
  ) -> some View {
    if let value {
      content(self,value)
    } else {
      self
    }
  }
}