//
//  File.swift
//  
//
//  Created by Luke Zhao on 6/8/21.
//

import UIKit

public struct TappableViewConfiguration {
    public static var `default` = TappableViewConfiguration(onHighlightChanged: nil, didTap: nil)
    
    /// place to apply highlight state or animation to the TappableView
    public var onHighlightChanged: ((TappableView, Bool) -> Void)?
    
    /// hook before the actual onTap is called
    public var didTap: ((TappableView) -> Void)?
    
    public init(onHighlightChanged: ((TappableView, Bool) -> Void)? = nil, didTap: ((TappableView) -> Void)? = nil) {
        self.onHighlightChanged = onHighlightChanged
        self.didTap = didTap
    }
}

open class TappableView: ComponentView {
    public var onTap: ((TappableView) -> Void)?
    public var configuration: TappableViewConfiguration?
    
    open var isHighlighted: Bool = false {
        didSet {
            guard isHighlighted != oldValue else { return }
            let config = configuration ?? TappableViewConfiguration.default
            config.onHighlightChanged?(self, isHighlighted)
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        accessibilityTraits = .button
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap)))
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        isHighlighted = true
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        isHighlighted = false
    }
    
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        isHighlighted = false
    }
    
    @objc open func didTap() {
        let config = configuration ?? TappableViewConfiguration.default
        config.didTap?(self)
        onTap?(self)
    }
}

extension Component {
    public func tappableView(configuration: TappableViewConfiguration? = nil,
                             _ onTap: @escaping (TappableView) -> Void) -> ViewUpdateComponent<ComponentDisplayableViewComponent<TappableView>> {
        ComponentDisplayableViewComponent<TappableView>(component: self).update {
            $0.onTap = onTap
            $0.configuration = configuration
        }
    }
    public func tappableView(configuration: TappableViewConfiguration? = nil,
                             _ onTap: @escaping () -> Void) -> ViewUpdateComponent<ComponentDisplayableViewComponent<TappableView>> {
        tappableView(configuration: configuration) { _ in
            onTap()
        }
    }
}
