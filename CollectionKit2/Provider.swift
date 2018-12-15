//
//  Provider.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-07-23.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

public protocol Provider {
  func layout(size: CGSize) -> CGSize
  func views(in frame: CGRect) -> [(UIView, CGRect)]
}

open class MultiChildProvider: Provider {
  open var children: [Provider] = []
  init(children: [Provider]) {
    self.children = children
  }
  open func layout(size: CGSize) -> CGSize {
    fatalError()
  }
  open func views(in frame: CGRect) -> [(UIView, CGRect)] {
    fatalError()
  }
}

open class SingleChildProvider: Provider {
  open var child: Provider
  init(child: Provider) {
    self.child = child
  }
  open func layout(size: CGSize) -> CGSize {
    fatalError()
  }
  open func views(in frame: CGRect) -> [(UIView, CGRect)] {
    fatalError()
  }
}

open class LayoutProvider: MultiChildProvider {
  public private(set) var frames: [CGRect] = []

  open func simpleLayout(size: CGSize) -> [CGRect] {
    fatalError("Subclass should provide its own layout")
  }

  open func doneLayout() {

  }

  open override func layout(size: CGSize) -> CGSize {
    frames = simpleLayout(size: size)
    let contentSize = frames.reduce(CGRect.zero) { (old, item) in
      old.union(item)
      }.size
    doneLayout()
    return contentSize
  }

  open override func views(in frame: CGRect) -> [(UIView, CGRect)] {
    var result = [(UIView, CGRect)]()
    for (i, childFrame) in frames.enumerated() where frame.intersects(childFrame) {
      let childResult = children[i].views(in: frame.intersection(childFrame)).map { ($0.0, CGRect(origin: $0.1.origin + childFrame.origin, size: $0.1.size)) }
      result.append(contentsOf: childResult)
    }
    return result
  }
}

class WaterfallLayoutProvider: LayoutProvider {
  public var columns: Int
  public var spacing: CGFloat
  private var columnWidth: [CGFloat] = [0, 0]
  private var maxSize = CGSize.zero

  public init(columns: Int = 2, spacing: CGFloat = 0, children: [Provider]) {
    self.columns = columns
    self.spacing = spacing
    super.init(children: children)
  }

  override func simpleLayout(size: CGSize) -> [CGRect] {
    var frames: [CGRect] = []

    let columnWidth = (size.width - CGFloat(columns - 1) * spacing) / CGFloat(columns)
    var columnHeight = [CGFloat](repeating: 0, count: columns)

    func getMinColomn() -> (Int, CGFloat) {
      var minHeight: (Int, CGFloat) = (0, columnHeight[0])
      for (index, height) in columnHeight.enumerated() where height < minHeight.1 {
        minHeight = (index, height)
      }
      return minHeight
    }

    for child in children {
      var cellSize = child.layout(size: size)
      cellSize = CGSize(width: columnWidth, height: cellSize.height)
      let (columnIndex, offsetY) = getMinColomn()
      columnHeight[columnIndex] += cellSize.height + spacing
      let frame = CGRect(origin: CGPoint(x: CGFloat(columnIndex) * (columnWidth + spacing),
                                         y: offsetY),
                         size: cellSize)
      frames.append(frame)
    }

    return frames
  }
}

open class WrapperProvider: SingleChildProvider {
  open override func layout(size: CGSize) -> CGSize {
    return child.layout(size: size)
  }

  open override func views(in frame: CGRect) -> [(UIView, CGRect)] {
    return child.views(in: frame)
  }
}

open class TransposeLayoutProvider: WrapperProvider {
  open override func layout(size: CGSize) -> CGSize {
    return child.layout(size: size.transposed).transposed
  }
  open override func views(in frame: CGRect) -> [(UIView, CGRect)] {
    return child.views(in: frame.transposed).map {
      ($0.0, $0.1.transposed)
    }
  }
}


let reuseManager = CollectionReuseViewManager()
open class ViewProvider<View: UIView>: Provider {

  public typealias ViewGenerator = () -> View
  public typealias ViewUpdater = (View) -> Void
  public typealias SizeGenerator = (CGSize) -> CGSize

  public var viewGenerator: ViewGenerator?
  public var viewUpdater: ViewUpdater?
  public var sizeSource: SizeGenerator?

  public init(update: ViewUpdater?, size: SizeGenerator?) {
    self.viewUpdater = update
    self.sizeSource = size
  }

  public func view() -> UIView {
    if let viewGenerator = viewGenerator {
      let view = reuseManager.dequeue(viewGenerator())
      update(view: view)
      return view
    } else {
      let view = reuseManager.dequeue(View())
      update(view: view)
      return view
    }
  }

  public func update(view: UIView) {
    guard let view = view as? View else { return }
    viewUpdater?(view)
  }

  var _size: CGSize = .zero
  public func layout(size: CGSize) -> CGSize {
    if let sizeSource = sizeSource {
      _size = sizeSource(size)
      return _size
    } else {
      return .zero
    }
  }

  public func views(in frame: CGRect) -> [(UIView, CGRect)] {
    return [(view(), CGRect(origin: .zero, size: _size))]
  }
}

protocol ViewMapper: Provider {
  associatedtype Data
  associatedtype View: UIView
  static var reuseKey: String { get }
  var key: String { get }
  func construct() -> View
  func update(view: View)
  func size(maxSize: CGSize) -> CGSize
}

extension ViewMapper {
  static var reuseKey: String {
    return "\(type(of:self))"
  }
  func construct() -> View {
    return View()
  }
  func layout(size: CGSize) -> CGSize {
    return self.size(maxSize: size)
  }
  func views(in frame: CGRect) -> [(UIView, CGRect)] {
    let view = reuseManager.dequeue(construct())
    update(view: view)
    return [(view, CGRect(origin: .zero, size: size(maxSize: UIScreen.main.bounds.size)))]
  }
}

struct LabelViewProvider: ViewMapper {
  var key: String = ""
  typealias Data = String
  let text: String
  func update(view: UILabel) {
    view.text = text
  }
  func size(maxSize: CGSize) -> CGSize {
    return CGSize(width: maxSize.width, height: 100)
  }
}
