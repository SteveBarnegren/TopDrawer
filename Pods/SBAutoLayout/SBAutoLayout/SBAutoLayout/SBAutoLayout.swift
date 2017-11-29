//
//  SBAutoLayout.swift
//  SBLayoutSwift
//
//  Created by Steven Barnegren on 26/04/2016.
//  Copyright © 2016 Steve Barnegren. All rights reserved.
//

import Foundation

#if os(OSX)
    import AppKit
    public typealias UIView = NSView
    public typealias UILayoutPriority = NSLayoutConstraint.Priority
    public typealias UIEdgeInsets = NSEdgeInsets
    public typealias NSLayoutAttribute = NSLayoutConstraint.Attribute
#else
    import UIKit
#endif

extension UIView {
    
    // MARK: - Pin Width / Height
    
    @discardableResult public func pinWidth(_ width: CGFloat, priority: UILayoutPriority? = nil) -> NSLayoutConstraint{
        
        translatesAutoresizingMaskIntoConstraints = false
        
        let constraint = NSLayoutConstraint.init(item: self,
                                                 attribute: .width,
                                                 relatedBy: .equal,
                                                 toItem: nil,
                                                 attribute: .notAnAttribute,
                                                 multiplier: 1,
                                                 constant: width)        
        if let priority = priority {
            constraint.priority = priority
        }
        
        addConstraint(constraint)
        return constraint
    }
    
    @discardableResult public func pinHeight(_ height: CGFloat, priority: UILayoutPriority? = nil) -> NSLayoutConstraint{
        
        translatesAutoresizingMaskIntoConstraints = false
        
        let constraint = NSLayoutConstraint.init(item: self,
                                                 attribute: .height,
                                                 relatedBy: .equal,
                                                 toItem: nil,
                                                 attribute: .notAnAttribute,
                                                 multiplier: 1,
                                                 constant: height)
        
        if let priority = priority {
            constraint.priority = priority
        }

        addConstraint(constraint)
        return constraint
    }
    
    @discardableResult public func pinAspectRatio(width: CGFloat, height: CGFloat, priority: UILayoutPriority? = nil) -> NSLayoutConstraint {
    
        translatesAutoresizingMaskIntoConstraints = false

        let constraint = NSLayoutConstraint.init(item: self,
                                                 attribute: .width,
                                                 relatedBy: .equal,
                                                 toItem: self,
                                                 attribute: .height,
                                                 multiplier: width/height,
                                                 constant: 0)
        
        if let priority = priority {
            constraint.priority = priority
        }
        
        addConstraint(constraint)
        return constraint
    }
    
    // MARK: - Pin to superview edges
    
    @discardableResult public func pinToSuperviewEdges(priority: UILayoutPriority? = nil) -> [NSLayoutConstraint]{
        return self.pinToSuperviewEdges(top: 0, bottom: 0, leading: 0, trailing: 0, priority: priority)
    }
    
    @discardableResult public func pinToSuperviewEdges(top: CGFloat, bottom: CGFloat, leading: CGFloat, trailing: CGFloat, priority: UILayoutPriority? = nil) -> [NSLayoutConstraint]{
        
        translatesAutoresizingMaskIntoConstraints = false
        
        var constraints = [NSLayoutConstraint]()
        constraints.append(pinToSuperviewTop(margin: top, priority: priority))
        constraints.append(pinToSuperviewBottom(margin: bottom, priority: priority))
        constraints.append(pinToSuperviewLeading(margin: leading, priority: priority))
        constraints.append(pinToSuperviewTrailing(margin: trailing, priority: priority))
        
        return constraints
    }
    
    @discardableResult public func pinToSuperviewEdges(insets: UIEdgeInsets, priority: UILayoutPriority? = nil) -> [NSLayoutConstraint]{
        
        translatesAutoresizingMaskIntoConstraints = false;
        
        var constraints = [NSLayoutConstraint]()
        constraints.append(pinToSuperviewTop(margin: insets.top, priority: priority))
        constraints.append(pinToSuperviewBottom(margin: insets.bottom, priority: priority))
        constraints.append(pinToSuperviewLeading(margin: insets.left, priority: priority))
        constraints.append(pinToSuperviewTrailing(margin: insets.right, priority: priority))
        
        return constraints
    }
    
    
    @discardableResult public func pinToSuperviewTop(margin: CGFloat, priority: UILayoutPriority? = nil) -> NSLayoutConstraint{
        return matchAttributeToSuperview(.top, constant: margin, priority: priority)
    }
    
    @discardableResult public func pinToSuperviewBottom(margin: CGFloat, priority: UILayoutPriority? = nil) -> NSLayoutConstraint{
        return matchAttributeToSuperview(.bottom, constant: margin, priority: priority, invert: true)
    }
    
    @discardableResult public func pinToSuperviewLeft(margin: CGFloat, priority: UILayoutPriority? = nil) -> NSLayoutConstraint{
        return matchAttributeToSuperview(.left, constant: margin, priority: priority)
    }
    
    @discardableResult public func pinToSuperviewRight(margin: CGFloat, priority: UILayoutPriority? = nil) -> NSLayoutConstraint{
        return matchAttributeToSuperview(.right, constant: margin, priority: priority, invert: true)
    }
    
    @discardableResult public func pinToSuperviewLeading(margin: CGFloat, priority: UILayoutPriority? = nil) -> NSLayoutConstraint{
        return matchAttributeToSuperview(.leading, constant: margin, priority: priority)
    }
    
    @discardableResult public func pinToSuperviewTrailing(margin: CGFloat, priority: UILayoutPriority? = nil) -> NSLayoutConstraint{
        return matchAttributeToSuperview(.trailing, constant: margin, priority: priority, invert: true)
    }
    
    // MARK: - Pin to superview as strip
    
    @discardableResult public func pinToSuperviewAsTopStrip(height: CGFloat, priority: UILayoutPriority? = nil) -> [NSLayoutConstraint]{
        
        var constraints = [NSLayoutConstraint]()
        constraints.append(pinToSuperviewTop(margin: 0, priority: priority))
        constraints.append(pinToSuperviewLeading(margin: 0, priority: priority))
        constraints.append(pinToSuperviewTrailing(margin: 0, priority: priority))
        constraints.append(pinHeight(height, priority: priority))
        
        return constraints
    }
    
    @discardableResult public func pinToSuperviewAsBottomStrip(height: CGFloat, priority: UILayoutPriority? = nil) -> [NSLayoutConstraint]{
        
        var constraints = [NSLayoutConstraint]()
        constraints.append(pinToSuperviewBottom(margin: 0, priority: priority))
        constraints.append(pinToSuperviewLeading(margin: 0, priority: priority))
        constraints.append(pinToSuperviewTrailing(margin: 0, priority: priority))
        constraints.append(pinHeight(height, priority: priority))
        
        return constraints
    }
    
    @discardableResult public func pinToSuperviewAsLeftStrip(width: CGFloat, priority: UILayoutPriority? = nil) -> [NSLayoutConstraint]{
        
        var constraints = [NSLayoutConstraint]()
        constraints.append(pinToSuperviewLeft(margin: 0, priority: priority))
        constraints.append(pinToSuperviewTop(margin: 0, priority: priority))
        constraints.append(pinToSuperviewBottom(margin: 0, priority: priority))
        constraints.append(pinWidth(width, priority: priority))
        
        return constraints
    }
    
    @discardableResult public func pinToSuperviewAsRightStrip(width: CGFloat, priority: UILayoutPriority? = nil) -> [NSLayoutConstraint]{
        
        var constraints = [NSLayoutConstraint]()
        constraints.append(pinToSuperviewRight(margin: 0, priority: priority))
        constraints.append(pinToSuperviewTop(margin: 0, priority: priority))
        constraints.append(pinToSuperviewBottom(margin: 0, priority: priority))
        constraints.append(pinWidth(width, priority: priority))
        
        return constraints
    }
    
    @discardableResult public func pinToSuperviewAsLeadingStrip(width: CGFloat, priority: UILayoutPriority? = nil) -> [NSLayoutConstraint]{
        
        var constraints = [NSLayoutConstraint]()
        constraints.append(pinToSuperviewLeading(margin: 0, priority: priority))
        constraints.append(pinToSuperviewTop(margin: 0, priority: priority))
        constraints.append(pinToSuperviewBottom(margin: 0, priority: priority))
        constraints.append(pinWidth(width, priority: priority))
        
        return constraints
    }
    
    @discardableResult public func pinToSuperviewAsTrailingStrip(width: CGFloat, priority: UILayoutPriority? = nil) -> [NSLayoutConstraint]{
        
        var constraints = [NSLayoutConstraint]()
        constraints.append(pinToSuperviewTrailing(margin: 0, priority: priority))
        constraints.append(pinToSuperviewTop(margin: 0, priority: priority))
        constraints.append(pinToSuperviewBottom(margin: 0, priority: priority))
        constraints.append(pinWidth(width, priority: priority))
        
        return constraints
    }
    
    // MARK: - Pin to superview center
    
    @discardableResult public func pinToSuperviewCenterX(offset: CGFloat = 0, priority: UILayoutPriority? = nil) -> NSLayoutConstraint{
        return matchAttributeToSuperview(.centerX, constant: offset)
    }
    
    @discardableResult public func pinToSuperviewCenterY(offset: CGFloat = 0, priority: UILayoutPriority? = nil) -> NSLayoutConstraint{
        return matchAttributeToSuperview(.centerY, constant: offset)
    }
    
    @discardableResult public func pinToSuperviewCenter(priority: UILayoutPriority? = nil) -> [NSLayoutConstraint]{
        
        var constraints = [NSLayoutConstraint]()
        constraints.append(pinToSuperviewCenterX(priority: priority))
        constraints.append(pinToSuperviewCenterY(priority: priority))
        return constraints
    }
    
    // MARK: - Pin Outside Superview
    @discardableResult public func pinOutsideSuperviewBottom(separation: CGFloat = 0, priority: UILayoutPriority? = nil) -> NSLayoutConstraint{
        
        translatesAutoresizingMaskIntoConstraints = false
        
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: .top,
                                            relatedBy: .equal,
                                            toItem: superview,
                                            attribute: .bottom,
                                            multiplier: 1,
                                            constant: separation)
        superview?.addConstraint(constraint)
        
        return constraint
    }
    
    @discardableResult public func pinOutsideSuperviewTop(separation: CGFloat = 0, priority: UILayoutPriority? = nil) -> NSLayoutConstraint{
        
        translatesAutoresizingMaskIntoConstraints = false
        
        guard let superview = superview else {
            bailNoSuperview()
        }
        
        let constraint = NSLayoutConstraint(item: superview,
                                            attribute: .top,
                                            relatedBy: .equal,
                                            toItem: self,
                                            attribute: .bottom,
                                            multiplier: 1,
                                            constant: separation)
        superview.addConstraint(constraint)
        
        return constraint
    }
    
    @discardableResult public func pinOutsideSuperviewLeft(separation: CGFloat = 0, priority: UILayoutPriority? = nil) -> NSLayoutConstraint{
        
        translatesAutoresizingMaskIntoConstraints = false
        
        guard let superview = superview else {
            bailNoSuperview()
        }
        
        let constraint = NSLayoutConstraint(item: superview,
                                            attribute: .left,
                                            relatedBy: .equal,
                                            toItem: self,
                                            attribute: .right,
                                            multiplier: 1,
                                            constant: separation)
        superview.addConstraint(constraint)
        
        return constraint
    }
    
    @discardableResult public func pinOutsideSuperviewRight(separation: CGFloat = 0, priority: UILayoutPriority? = nil) -> NSLayoutConstraint{
        
        translatesAutoresizingMaskIntoConstraints = false
        
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: .left,
                                            relatedBy: .equal,
                                            toItem: superview,
                                            attribute: .right,
                                            multiplier: 1,
                                            constant: separation)
        superview?.addConstraint(constraint)

        return constraint
    }
    
    // MARK:- Pin to other views

    @discardableResult public func pinAboveView(_ otherView: UIView, separation: CGFloat = 0, priority: UILayoutPriority? = nil) -> NSLayoutConstraint{
        
        translatesAutoresizingMaskIntoConstraints = false
        otherView.translatesAutoresizingMaskIntoConstraints = false
        
        let constraint = NSLayoutConstraint(item: otherView,
                                            attribute: .top,
                                            relatedBy: .equal,
                                            toItem: self,
                                            attribute: .bottom,
                                            multiplier: 1,
                                            constant: separation)
        
        if let priority = priority {
            constraint.priority = priority
        }
        
        commonSuperviewWithView(otherView).addConstraint(constraint)
        return constraint
    }
    
    @discardableResult public func pinBelowView(_ otherView: UIView, separation: CGFloat = 0, priority: UILayoutPriority? = nil) -> NSLayoutConstraint{
        return otherView.pinAboveView(self, separation: separation, priority: priority)
    }
    
    @discardableResult public func pinToLeftOfView(_ otherView: UIView, separation: CGFloat = 0, priority: UILayoutPriority? = nil) -> NSLayoutConstraint{
        
        translatesAutoresizingMaskIntoConstraints = false
        otherView.translatesAutoresizingMaskIntoConstraints = false
        
        let constraint = NSLayoutConstraint(item: otherView,
                                            attribute: .left,
                                            relatedBy: .equal,
                                            toItem: self,
                                            attribute: .right,
                                            multiplier: 1,
                                            constant: separation)
        
        if let priority = priority {
            constraint.priority = priority
        }
        
        commonSuperviewWithView(otherView).addConstraint(constraint)
        return constraint
    }
    
    @discardableResult public func pinToRightOfView(_ otherView: UIView, separation: CGFloat = 0, priority: UILayoutPriority? = nil) -> NSLayoutConstraint{
        return otherView.pinToLeftOfView(self, separation: separation, priority: priority)
    }
    
    @discardableResult public func pinTrailingFromView(_ otherView: UIView, separation: CGFloat = 0, priority: UILayoutPriority? = nil) -> NSLayoutConstraint{
        
        translatesAutoresizingMaskIntoConstraints = false
        otherView.translatesAutoresizingMaskIntoConstraints = false
        
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: .leading,
                                            relatedBy: .equal,
                                            toItem: otherView,
                                            attribute: .trailing,
                                            multiplier: 1,
                                            constant: separation)
        
        if let priority = priority {
            constraint.priority = priority
        }
        
        commonSuperviewWithView(otherView).addConstraint(constraint)
        return constraint
    }
    
    @discardableResult public func pinLeadingToView(_ otherView: UIView, separation: CGFloat = 0, priority: UILayoutPriority? = nil) -> NSLayoutConstraint{
        return otherView.pinTrailingFromView(self, separation: separation, priority: priority)
    }
    
    @discardableResult public func pinWidthToSameAsView(_ otherView: UIView, priority: UILayoutPriority? = nil) -> NSLayoutConstraint{
        
        translatesAutoresizingMaskIntoConstraints = false
        otherView.translatesAutoresizingMaskIntoConstraints = false
        
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: .width,
                                            relatedBy: .equal,
                                            toItem: otherView,
                                            attribute: .width,
                                            multiplier: 1,
                                            constant: 0)
        
        if let priority = priority {
            constraint.priority = priority
        }
        
        commonSuperviewWithView(otherView).addConstraint(constraint)
        return constraint
    }
    
    @discardableResult public func pinHeightToSameAsView(_ otherView: UIView, priority: UILayoutPriority? = nil) -> NSLayoutConstraint{
        
        translatesAutoresizingMaskIntoConstraints = false
        otherView.translatesAutoresizingMaskIntoConstraints = false
        
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: .height,
                                            relatedBy: .equal,
                                            toItem: otherView,
                                            attribute: .height,
                                            multiplier: 1,
                                            constant: 0)
        
        if let priority = priority {
            constraint.priority = priority
        }
        
        commonSuperviewWithView(otherView).addConstraint(constraint)
        return constraint
    }

    // MARK:- Private
    
    private func matchAttributeToSuperview(_ attribute: NSLayoutAttribute,
                                           multiplier: CGFloat = 1,
                                           constant: CGFloat = 0,
                                           priority: UILayoutPriority? = nil,
                                           invert: Bool = false) -> NSLayoutConstraint{
        
        translatesAutoresizingMaskIntoConstraints = false
        
        let constraint = NSLayoutConstraint(item: (invert ? superview! : self),
                                            attribute: attribute,
                                            relatedBy: .equal,
                                            toItem: (invert ? self : superview!),
                                            attribute: attribute,
                                            multiplier: multiplier,
                                            constant: constant)
        
        if let priority = priority {
            constraint.priority = priority
        }
        
        superview!.addConstraint(constraint)
        return constraint
    }
    
    private func commonSuperviewWithView(_ otherView: UIView) -> UIView {
        
        var testView = self
        
        while otherView.isDescendant(of: testView) == false {
            
            guard let superview = testView.superview else {
                Swift.print("Views must share a common superview")
                abort()
            }
            
            testView = superview
        }
        
       return testView
    }
    
    func bailNoSuperview() -> Never {
        fatalError("Add view to superview before setting constraints!")
    }
    
}
