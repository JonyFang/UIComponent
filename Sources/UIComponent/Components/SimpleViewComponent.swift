//
//  File.swift
//  
//
//  Created by Luke Zhao on 8/23/20.
//

import UIKit

public struct SimpleViewComponent<View: UIView>: ViewComponent {
    public let view: View?
    public let generator: (() -> View)?
    private init(view: View?, generator: (() -> View)?) {
        self.view = view
        self.generator = generator
    }
    public init(view: View? = nil) {
        self.init(view: view, generator: nil)
    }
    public init(id: String? = nil, generator: @autoclosure @escaping () -> View) {
        self.init(view: nil, generator: generator)
    }
    public func layout(_ constraint: Constraint) -> SimpleViewRenderer<View> {
        SimpleViewRenderer(size: (view?.sizeThatFits(constraint.maxSize) ?? .zero).bound(to: constraint), view: view, generator: generator)
    }
}

public struct SimpleViewRenderer<View: UIView>: ViewRenderer {
    public let size: CGSize
    public let view: View?
    public let generator: (() -> View)?
    public var id: String? {
        if let view = view {
            return "view-at-\(Unmanaged.passUnretained(view).toOpaque())"
        }
        return nil
    }
    public var reuseKey: String? {
        return view == nil ? "\(type(of: self))" : nil
    }
    
    fileprivate init(size: CGSize, view: View?, generator: (() -> View)?) {
        self.size = size
        self.view = view
        self.generator = generator
    }
    
    public init(size: CGSize) {
        self.init(size: size, view: nil, generator: nil)
    }
    
    public init(size: CGSize, view: View) {
        self.init(size: size, view: view, generator: nil)
    }
    
    public init(size: CGSize, generator: @escaping (() -> View)) {
        self.init(size: size, view: nil, generator: generator)
    }
    
    public func makeView() -> View {
        if let view = view {
            return view
        } else if let generator = generator {
            return generator()
        } else {
            return View()
        }
    }
    
    public func updateView(_ view: View) {}
}

extension UIView: ViewComponent {
    public func layout(_ constraint: Constraint) -> some ViewRenderer {
        SimpleViewRenderer(size: sizeThatFits(constraint.maxSize).bound(to: constraint), view: self)
    }
}
