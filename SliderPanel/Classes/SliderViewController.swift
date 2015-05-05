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
    
    private let overlay = UIButton()

    lazy var widthConstraint: NSLayoutConstraint =  {
       //return NSLayoutConstraint(item: self.contentView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: self.panelWidth())
        return NSLayoutConstraint(item: self.contentView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: self.panelWidthOpened())
    }()
    
    var positionConstraint: NSLayoutConstraint?
    
    
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
        
        if configuration.shadowEnabled {
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
        
        self.view.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        self.willMoveToParentViewController(viewController)
        viewController.addChildViewController(self)
        viewController.view.addSubview(self.view)
        
        //use full vertical size
        viewController.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[panel]|", options: NSLayoutFormatOptions(0), metrics: nil, views: ["panel": self.view]))
        
        // pin left or right, according to the slider configuration
        var attribute = NSLayoutAttribute.Left
        if configuration.position == .Right {
            attribute = NSLayoutAttribute.Right
        }
        //viewController.view.addConstraint(NSLayoutConstraint(item: self.view, attribute: attribute, relatedBy: .Equal, toItem: viewController.view, attribute: attribute, multiplier: 1, constant: 0))
        
        positionConstraint = NSLayoutConstraint(item: self.view, attribute: attribute, relatedBy: .Equal, toItem: viewController.view, attribute: attribute, multiplier: 1,
            constant: -panelWidthOpened() )
        viewController.view.addConstraint(positionConstraint!)
        
        
        //widthConstraint.constant = panelWidth()
        viewController.view.addConstraint(widthConstraint)
        
        self.didMoveToParentViewController(viewController)
        
        if configuration.isModal {
            addModalOverlayToViewController(viewController)
        }
    }
    
    /**
    Add the viewController for the content.
    
    :param: viewController UIViewController that will added as the content
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
    
    func openPanel() {
        
        currentState = .Opened
        
        //widthConstraint.constant = panelWidth()
        positionConstraint?.constant = 0
        
        self.view.superview!.setNeedsUpdateConstraints()
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.view.superview!.layoutIfNeeded()
            
            self.overlay.alpha = 0.4
        })
        
        draggerView.displayImageForState(currentState, animated: true)
    }
    
    func closePanel() {
        
        currentState = .Closed
        
        //widthConstraint.constant = panelWidth()
        positionConstraint?.constant = -panelWidthOpened()
        
        self.view.superview!.setNeedsUpdateConstraints()
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.view.superview!.layoutIfNeeded()
            
            self.overlay.alpha = 0.0
        })
        
        draggerView.displayImageForState(currentState, animated: true)
    }
    
    override func willAnimateRotationToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        
        //call open again to set the correct width according to the changed width of the parent view
        if currentState == .Opened {
            openPanel()
        }
    }

    private func addModalOverlayToViewController(viewController: UIViewController) {
        
        overlay.backgroundColor = UIColor.blackColor()
        overlay.alpha = 0.0
        overlay.setTranslatesAutoresizingMaskIntoConstraints(false)
        overlay.addTarget(self, action: Selector("pressedBackground"), forControlEvents: UIControlEvents.TouchUpInside)
        
        viewController.view.insertSubview(overlay, belowSubview: self.view)
        viewController.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: NSLayoutFormatOptions(0), metrics: nil, views: ["view": overlay]))
        viewController.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: NSLayoutFormatOptions(0), metrics: nil, views: ["view": overlay]))
    }
    
    @objc private func pressedBackground() {
        if currentState == .Opened { //close it
            closePanel()
        }
    }
    
    @objc private func tapRecognized(recognizer: UITapGestureRecognizer) {
        
        if recognizer.state == .Ended {
            
            if currentState == .Opened {
                closePanel()
                
                widthConstraint.constant = panelWidthOpened()
            }
            else {
                openPanel()
            }
        }
    }
    
    @objc private func panRecognized(recognizer: UIPanGestureRecognizer) {
        
        let velocity = recognizer.velocityInView(self.view)

        let position = recognizer.translationInView(self.view.superview!)
        
        let location = recognizer.locationInView(self.view.superview!)
        
        let maxPosition = panelWidthOpened()
        
        let currentPosition: (CGFloat) = {
            if self.configuration.position == .Right {
                return self.view.superview!.frame.size.width - position.x
            }
            else {
                return position.x
            }
        }()
        
        if recognizer.state == .Changed {

            if velocity.x > 0 {
                
                // be sure that the panel can not move into the screen and is attached to the edge
                if positionConstraint?.constant > 0 {
                    positionConstraint?.constant = 0
                }
                
                if positionConstraint?.constant < 0 {

                    positionConstraint?.constant = location.x - panelWidthOpened()
                }
                
                else if positionConstraint?.constant == 0 && configuration.expandable && location.x >= panelWidthOpened() {
                    
                    widthConstraint.constant = location.x
                }
                
            }
            else {
                
                if location.x > panelWidthOpened() {
                    
                    widthConstraint.constant = location.x
                    
                    positionConstraint?.constant = 0
                }
                
                else  {
                    
                    positionConstraint?.constant = location.x - panelWidthOpened()
                }
            }
            

        }
            
        else if recognizer.state == .Ended {

            if (configuration.position == .Left && velocity.x > 0) || (configuration.position == .Right && velocity.x < 0) {

                openPanel()
                
                if !configuration.stayExpanded {
                    widthConstraint.constant = panelWidthOpened()
                }
            }
            //else {
            else if location.x <= panelWidthOpened() {
                
                closePanel()
                
                widthConstraint.constant = panelWidthOpened()
            }
            else {
                openPanel()
            }
        }
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
