//
//  SliderViewController.swift
//  SliderPanel
//
//  Created by seb on 26.03.15.
//  Copyright (c) 2015 seb. All rights reserved.
//

import Foundation
import UIKit

enum SliderState {
    case Opened
    case Closed
}

class SliderViewController: UIViewController {
    
    private let contentView = UIView()
    private var draggerView = SliderDraggerView()
    
    private var configuration = SliderConfiguration()
    private var currentState = SliderState.Closed
    
    private var addedViewController: UIViewController?
    
    lazy var widthConstraint: NSLayoutConstraint = {
        return NSLayoutConstraint(item: self.contentView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 0)
    }()
    
    
    convenience init(configuration: SliderConfiguration) {
        self.init()
        self.configuration = configuration
        self.draggerView = SliderDraggerView(configuration: configuration)
    }
    
    override func viewDidLoad() {
        
        contentView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view.addSubview(contentView)
        
        draggerView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view.addSubview(draggerView)
        
        contentView.backgroundColor = configuration.contentBackgroundColor
        draggerView.backgroundColor = configuration.draggerBackgroundColor
        
        let draggerWidth = configuration.draggerWidth
        
        var hFormat = "H:|[contentView][draggerView(w)]|"
        if configuration.position == SliderPosition.Right {
            hFormat = "H:|[draggerView(w)][contentView]|"
        }
        
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(hFormat, options: NSLayoutFormatOptions(0), metrics: ["w": draggerWidth], views: ["contentView": contentView, "draggerView": draggerView] ))
        
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[contentView]|", options: NSLayoutFormatOptions(0), metrics: nil, views: ["contentView": contentView]))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[draggerView]|", options: NSLayoutFormatOptions(0), metrics: nil, views: ["draggerView": draggerView]))
        
        draggerView.displayImageForState(currentState, animated: false)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: Selector("tapRecognized:"))
        draggerView.addGestureRecognizer(tapRecognizer)
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action: Selector("panRecognized:"))
        draggerView.addGestureRecognizer(panRecognizer)
        
        if configuration.enableShadow {
            self.contentView.layer.shadowColor = UIColor.lightGrayColor().CGColor
            self.contentView.layer.shadowRadius = 5
            self.contentView.layer.shadowOpacity = 0.8
        }
    }
    
    
    /**
    Add the slider panel to the given viewController.
    
    :param: viewController UIViewController on which the panel will be added
    */
    func addSliderToViewController(viewController: UIViewController) {
        
        addedViewController = viewController
        
        viewController.view.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        self.willMoveToParentViewController(viewController)
        viewController.addChildViewController(self)
        viewController.view.addSubview(self.view)
        
        viewController.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[panel]|", options: NSLayoutFormatOptions(0), metrics: nil, views: ["panel": self.view]))
        
        if configuration.position == .Left {
            let leftConst = NSLayoutConstraint(item: self.view, attribute: .Left, relatedBy: .Equal, toItem: viewController.view, attribute: .Left, multiplier: 1, constant: 0)
            viewController.view.addConstraint(leftConst)
        }
        else {
            let rightConst = NSLayoutConstraint(item: self.view, attribute: .Right, relatedBy: .Equal, toItem: viewController.view, attribute: .Right, multiplier: 1, constant: 0)
            viewController.view.addConstraint(rightConst)
        }
        
        widthConstraint.constant = panelWidth()
        viewController.view.addConstraint(widthConstraint)
        
        self.didMoveToParentViewController(viewController)
    }
    
    /**
    Add the viewController for the content.
    
    :param: viewController UIViewController that will add as the content
    */
    func addContentViewController(viewController: UIViewController) {
        
        viewController.view.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        viewController.willMoveToParentViewController(self)
        self.addChildViewController(viewController)
        contentView.addSubview(viewController.view)
        
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: NSLayoutFormatOptions(0), metrics: nil, views: ["view": viewController.view]))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: NSLayoutFormatOptions(0), metrics: nil, views: ["view": viewController.view]))
        
        viewController.didMoveToParentViewController(self)
    }
    
    override func willAnimateRotationToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        
        if currentState == .Opened {
            widthConstraint.constant = panelWidth()
        }
        
        animateWidthChange()
    }

    
    @objc private func tapRecognized(recognizer: UITapGestureRecognizer) {
        
        if recognizer.state == .Ended {
            
            if currentState == .Opened { //close it
                currentState = .Closed
            }
            else { //open it
                currentState = .Opened
            }
            
            widthConstraint.constant = panelWidth()
            
            animateWidthChange()
            
            draggerView.displayImageForState(currentState, animated: true)
        }
    }
    
    @objc private func panRecognized(recognizer: UIPanGestureRecognizer) {
        
        let translation = recognizer.translationInView(self.view)
        
        let velocity = recognizer.velocityInView(self.view)
        println("vel \(velocity.x)")
        
        let position = recognizer.locationInView(self.view.superview!)
        
        
        let maxPosition = panelWidthOpened()
        
        if recognizer.state == .Changed {

            if position.x >= 0 {
                if configuration.position == .Right {
                    widthConstraint.constant = (self.view.superview!.frame.size.width - position.x)
                }
                else {
                    widthConstraint.constant = position.x
                }
                
            }
        }
        else if recognizer.state == .Ended {

            //if widthConstraint.constant >= panelWidthOpened()/2 || position.x >= maxPosition {
            //if position.x >= maxPosition || velocity.x > 0 {
            
            //if widthConstraint.constant >= maxPosition || velocity.x > 0 {
            if configuration.position == .Left && velocity.x > 0 { //shall be opened
                draggerView.displayImageForState(.Opened, animated: true)
                
                widthConstraint.constant = maxPosition
                currentState = .Opened
            }
            else if configuration.position == .Right && velocity.x < 0 {
                draggerView.displayImageForState(.Opened, animated: true)
                
                widthConstraint.constant = maxPosition
                currentState = .Opened
            }
            else { //shall be closed
                draggerView.displayImageForState(.Closed, animated: true)
                
                widthConstraint.constant = panelWidthClosed()
                currentState = .Closed
            }
            
            animateWidthChange(duration: 0.15)
        }
    }
    
    private func animateWidthChange(duration: NSTimeInterval = 0.3) {
        
        self.view.superview!.setNeedsUpdateConstraints()
        
        UIView.animateWithDuration(duration, animations: { () -> Void in
            self.view.superview!.layoutIfNeeded()
        })
    }
    
    private func panelWidthOpened() -> CGFloat {
        if let width = configuration.widthOpened {
            return width
        }
        else {
            return CGFloat(self.view.superview!.frame.size.width / 3)
        }
    }
    
    private func panelWidthClosed() -> CGFloat {
        return configuration.widthClosed
    }
    
    private func panelWidth() -> CGFloat {
        
        if currentState == .Closed {
            return panelWidthClosed()
        }
        else {
            return panelWidthOpened()
        }
    }
    
}
