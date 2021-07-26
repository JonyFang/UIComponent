//
//  AnimatedReloadAnimator.swift
//  UIComponent
//
//  Created by Luke Zhao on 2018-12-27.
//  Copyright © 2018 Luke Zhao. All rights reserved.
//

import UIKit

public class AnimatedReloadAnimator: Animator {
    public static let defaultEntryTransform: CATransform3D = CATransform3DTranslate(CATransform3DScale(CATransform3DIdentity, 0.8, 0.8, 1), 0, 0, -10)
    public static let fancyEntryTransform: CATransform3D = {
        var trans = CATransform3DIdentity
        trans.m34 = -1 / 500
        return CATransform3DScale(CATransform3DRotate(CATransform3DTranslate(trans, 0, -50, -100), 0.5, 1, 0, 0), 0.8, 0.8, 1)
    }()
    
    let entryTransform: CATransform3D
    
    public init(entryTransform: CATransform3D = defaultEntryTransform) {
        self.entryTransform = entryTransform
        super.init()
    }
    
    public override func delete(componentView: ComponentDisplayableView, view: UIView) {
        if componentView.isReloading, componentView.bounds.intersects(view.frame) {
            UIView.animate(withDuration: 0.25, animations: {
                view.layer.transform = self.entryTransform
                view.alpha = 0
            }, completion: { _ in
                if !componentView.visibleViews.contains(view) {
                    view.transform = CGAffineTransform.identity
                    view.alpha = 1
                    view.recycleForUIComponentReuse()
                }
            })
        } else {
            view.recycleForUIComponentReuse()
        }
    }
    
    public override func insert(componentView: ComponentDisplayableView, view: UIView, frame: CGRect) {
        view.bounds = frame.bounds
        view.center = frame.center
        if componentView.isReloading, componentView.hasReloaded, componentView.bounds.intersects(frame) {
            let offsetTime: TimeInterval = TimeInterval(frame.origin.distance(componentView.bounds.origin) / 3000)
            view.layer.transform = entryTransform
            view.alpha = 0
            UIView.animate(withDuration: 0.5, delay: offsetTime, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
                view.transform = .identity
                view.alpha = 1
            })
        }
    }
    
    public override func update(componentView _: ComponentDisplayableView, view: UIView, frame: CGRect) {
        if view.center != frame.center {
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: [.layoutSubviews], animations: {
                view.center = frame.center
            }, completion: nil)
        }
        if view.bounds.size != frame.bounds.size {
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: [.layoutSubviews], animations: {
                view.bounds.size = frame.bounds.size
            }, completion: nil)
        }
        if view.alpha != 1 || view.transform != .identity {
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: [], animations: {
                view.transform = .identity
                view.alpha = 1
            }, completion: nil)
        }
    }
}
