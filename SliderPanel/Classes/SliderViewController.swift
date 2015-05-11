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
        return NSLayoutConstraint(item: self.contentView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: self.panelWidthOpened())
    }()
    
    var positionConstraint: NSLayoutConstraint!
    
    
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
        
        positionConstraint = NSLayoutConstraint(item: self.view,
            attribute: attribute,
            relatedBy: .Equal,
            toItem: viewController.view,
            attribute: attribute,
            multiplier: 1,
            constant: configuration.position == .Left ? -panelWidthOpened() : panelWidthOpened() )
        
        viewController.view.addConstraint(positionConstraint)
        
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
    
    /**
    Open the panel.
    The width of the panel will not be changed, only gthe position.
    */
    func openPanel() {
        
        currentState = .Opened
        
        positionConstraint.constant = 0
        
        self.view.superview!.setNeedsUpdateConstraints()
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.view.superview!.layoutIfNeeded()
            
            self.overlay.alpha = 0.4
        })
        
        draggerView.displayImageForState(currentState, animated: true)
    }
    
    /**
    Close the panel.
    This method will change the position, so it is outside of the screen and will set the width of the panel to the default or set one.
    */
    func closePanel() {
        
        currentState = .Closed
        
        positionConstraint.constant = configuration.position == .Left ? -panelWidthOpened() : panelWidthOpened()
        widthConstraint.constant = panelWidthOpened()
        
        self.view.superview!.setNeedsUpdateConstraints()
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.view.superview!.layoutIfNeeded()
            
            self.overlay.alpha = 0.0
        })
        
        draggerView.displayImageForState(currentState, animated: true)
    }
    
    override func willAnimateRotationToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        
        // call openPanel() again to set the correct width according to the changed width of the parent view
        if currentState == .Opened {
            openPanel()
        }
    }

    /**
    Add a transparent (black color with alpha) view.
    This is used when the panel is opened.
    :param: viewController UIViewController that is used to insert the gray view
    */
    private func addModalOverlayToViewController(viewController: UIViewController) {
        
        overlay.backgroundColor = UIColor.blackColor()
        overlay.alpha = 0.0
        overlay.setTranslatesAutoresizingMaskIntoConstraints(false)
        overlay.addTarget(self, action: Selector("pressedBackground"), forControlEvents: UIControlEvents.TouchUpInside)
        
        viewController.view.insertSubview(overlay, belowSubview: self.view)
        viewController.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: NSLayoutFormatOptions(0), metrics: nil, views: ["view": overlay]))
        viewController.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: NSLayoutFormatOptions(0), metrics: nil, views: ["view": overlay]))
    }
    
    /**
    Grayed background is pressed. This will close the panel.
    */
    @objc private func pressedBackground() {
        if currentState == .Opened { //close it
            closePanel()
        }
    }
    
    /**
    A tap on the dragger is recognized.
    This will open or close the panel (according to the current state).
    :param: recognizer UITapGestureRecognizer
    */
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
    
    /**
    Moving gesture recognized.
    This will move the panel according to the options (expandable, stayExpanded, ...).
    :param: recognizer UIPanGestureRecognizer
    */
    @objc private func panRecognized(recognizer: UIPanGestureRecognizer) {
        
        let velocity = recognizer.velocityInView(self.view)

        let position = recognizer.translationInView(self.view.superview!)
        
        let location: (CGFloat) = {
            if self.configuration.position == .Right {
                return self.view.superview!.bounds.size.width - recognizer.locationInView(self.view.superview!).x
            }
            else {
                return recognizer.locationInView(self.view.superview!).x
            }
        }()
        
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

            if configuration.position == .Left {
                
                if velocity.x > 0 { // open
                    
                    // be sure that the panel can not move into the screen and is attached to the edge
                    if positionConstraint.constant > 0 {
                        positionConstraint.constant = 0
                    }
                    // move the panel into the screen
                    if positionConstraint.constant < 0 {
                        
                        positionConstraint.constant = location - panelWidthOpened()
                    }
                    // panel is opened - change only the width when it is expandable
                    else if positionConstraint.constant == 0 && configuration.expandable && location >= panelWidthOpened() {
                        
                        widthConstraint.constant = location
                    }
                    
                }
                else { //close
                    
                    // panel is expanded - first close the expanded width
                    if location > panelWidthOpened() {
                        
                        widthConstraint.constant = location
                        
                        positionConstraint.constant = 0
                    }
                    // panel is not expanded - movie it out of the screen
                    else  {
                        
                        positionConstraint.constant = location - panelWidthOpened()
                    }
                }
            }
                
            else { // .Right
                
                if velocity.x < 0 { // open

                    // be sure that the panel can not move into the screen and is attached to the edge
                    if positionConstraint.constant <= 0 {
                        positionConstraint.constant = 0
                    }
                    // move the panel into the screen
                    else if positionConstraint.constant <= panelWidthOpened() && positionConstraint.constant > 0 {

                        positionConstraint.constant = panelWidthOpened() - abs(position.x)
                    }
                    // panel is opened and is expandable - change the width
                    if positionConstraint.constant == 0 && configuration.expandable {
                        
                        widthConstraint.constant = location
                    }
                    
                }
                else { // close
                    
                    // panel is expanded - change the width
                    if positionConstraint.constant == 0 && location >= panelWidthOpened() {
                        
                        widthConstraint.constant = location //only change the width

                    }
                    // panel is not expanded
                    else {
                        // finger is at the position of the panel
                        if location <= panelWidthOpened() {
                            
                            // move the panel
                            positionConstraint.constant = panelWidthOpened() - location
                            
                        }
                    }
                }
                
            } // .Right
            
        }
            
        else if recognizer.state == .Ended {

            // open the panel when the user moved the panel into the screen
            if (configuration.position == .Left && velocity.x > 0) || (configuration.position == .Right && velocity.x < 0) {

                openPanel()
                
                if !configuration.stayExpanded {
                    widthConstraint.constant = panelWidthOpened()
                }
            }
            // the panel was not opened completly by the user and the moving direction changed (into the closing direction).
            else if location <= panelWidthOpened() {
                
                closePanel()
                
                widthConstraint.constant = panelWidthOpened()
            }
            else {
                if configuration.position == .Left {
                    openPanel()
                }
                else {
                    // be sure to keep the panel at the position/width when it can stay expanded, or change the panel when stayExpanded is false
                    if !configuration.stayExpanded {
                        if widthConstraint.constant >= panelWidthOpened() {
                            widthConstraint.constant = panelWidthOpened()
                            openPanel()
                        }
                        else {
                            closePanel()
                        }
                    }
                    else {
                        openPanel()
                    }
                }
                
            }
        }
    }
    
    /**
    When `width`is set in the configuration this value will be used. Otherwise 1/3 of the screeen will be used.
    
    :returns: Width of the panel when it is opened
    */
    private func panelWidthOpened() -> CGFloat {
        if let width = configuration.width {
            return width
        }
        else {
            return CGFloat(self.view.superview!.frame.size.width / 3)
        }
    }
    
}
