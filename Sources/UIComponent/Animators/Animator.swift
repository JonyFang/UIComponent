//
//  Animator.swift
//  ComponentView
//
//  Created by Luke Zhao on 2017-07-19.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

open class Animator {
    /// Called before ComponentView perform any update to the cells.
    /// This method is only called when your animator is the componentView's root animator (i.e. componentView.animator)
    ///
    /// - Parameters:
    ///   - componentView: the ComponentView performing the update
    open func willUpdate(componentView _: ComponentDisplayableView) {}
    
    /// Called when ComponentView inserts a view into its subviews.
    ///
    /// Perform any insertion animation when needed
    ///
    /// - Parameters:
    ///   - componentView: source ComponentView
    ///   - view: the view being inserted
    ///   - at: index of the view inside the ComponentView (after flattening step)
    ///   - frame: frame provided by the layout
    open func insert(componentView _: ComponentDisplayableView,
                     view _: UIView,
                     frame _: CGRect) {}
    
    /// Called when ComponentView deletes a view from its subviews.
    ///
    /// Perform any deletion animation, then call `enqueue(view: view)`
    /// after the animation finishes
    ///
    /// - Parameters:
    ///   - componentView: source ComponentView
    ///   - view: the view being deleted
    open func delete(componentView _: ComponentDisplayableView,
                     view: UIView) {
        view.recycleForUIComponentReuse()
    }
    
    /// Called when:
    ///   * the view has just been inserted
    ///   * the view's frame changed after `reloadData`
    ///   * the view's screen position changed when user scrolls
    ///
    /// - Parameters:
    ///   - componentView: source ComponentView
    ///   - view: the view being updated
    ///   - at: index of the view inside the ComponentView (after flattening step)
    ///   - frame: frame provided by the layout
    open func update(componentView _: ComponentDisplayableView,
                     view: UIView,
                     frame: CGRect) {
        if view.bounds.size != frame.bounds.size {
            view.bounds.size = frame.bounds.size
        }
        if view.center != frame.center {
            view.center = frame.center
        }
    }
    
    /// Called when contentOffset changes during reloadData
    ///
    /// - Parameters:
    ///   - componentView: source ComponentView
    ///   - delta: changes in contentOffset
    ///   - view: the view being updated
    ///   - at: index of the view inside the ComponentView (after flattening step)
    ///   - frame: frame provided by the layout
    open func shift(componentView _: ComponentDisplayableView,
                    delta: CGPoint,
                    view: UIView,
                    frame _: CGRect) {
        view.center += delta
    }
    
    public init() {}
}
