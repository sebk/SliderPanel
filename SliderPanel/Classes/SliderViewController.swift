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
        return NSLayoutConstraint(item: self.contentView,
                                  attribute: .width,
                                  relatedBy: .equal,
                                  toItem: nil,
                                  attribute: .notAnAttribute,
                                  multiplier: 1,
                                  constant: self.panelWidthOpened())
    }()
    
    var positionConstraint: NSLayoutConstraint!
    
    
    convenience init(configuration: SliderConfiguration) {
        self.init()
        self.configuration = configuration
        self.draggerView = SliderDraggerView(configuration: configuration)
    }
    
    override func viewDidLoad() {
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(contentView)
        
        draggerView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(draggerView)
        
        contentView.backgroundColor = configuration.contentBackgroundColor
        draggerView.backgroundColor = configuration.draggerBackgroundColor
        
        let draggerWidth = configuration.draggerWidth
        
        var hFormat = "H:|[contentView][draggerView(w)]|"
        if configuration.position == SliderPosition.Right {
            hFormat = "H:|[draggerView(w)][contentView]|"
        }
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: hFormat,
                                                                options: NSLayoutFormatOptions(rawValue: 0),
                                                                metrics: ["w": draggerWidth],
                                                                views: ["contentView": contentView, "draggerView": draggerView] ))
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[contentView]|",
                                                                options: NSLayoutFormatOptions(rawValue: 0),
                                                                metrics: nil,
                                                                views: ["contentView": contentView]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[draggerView]|",
                                                                options: NSLayoutFormatOptions(rawValue: 0),
                                                                metrics: nil,
                                                                views: ["draggerView": draggerView]))
        
        draggerView.displayImageForState(state: currentState, animated: false)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(SliderViewController.tapRecognized(_:)))
        draggerView.addGestureRecognizer(tapRecognizer)
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(SliderViewController.panRecognized(_:)))
        draggerView.addGestureRecognizer(panRecognizer)
        
        if configuration.shadowEnabled {
            self.contentView.layer.shadowColor = UIColor.lightGray.cgColor
            self.contentView.layer.shadowRadius = 5
            self.contentView.layer.shadowOpacity = 0.8
        }
    }
    
    
    /**
    Add the slider panel to the given viewController.
    
    - parameter viewController: UIViewController on which the panel will be added
    */
    func addSliderToViewController(viewController: UIViewController) {
        
        self.view.translatesAutoresizingMaskIntoConstraints = false
        
        self.willMove(toParentViewController: viewController)
        viewController.addChildViewController(self)
        viewController.view.addSubview(self.view)
        
        //use full vertical size
        viewController.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[panel]|",
                                                                          options: NSLayoutFormatOptions(rawValue: 0),
                                                                          metrics: nil,
                                                                          views: ["panel": self.view]))
        
        // pin left or right, according to the slider configuration
        var attribute = NSLayoutAttribute.left
        if configuration.position == .Right {
            attribute = NSLayoutAttribute.right
        }
        
        positionConstraint = NSLayoutConstraint(item: self.view,
            attribute: attribute,
            relatedBy: .equal,
            toItem: viewController.view,
            attribute: attribute,
            multiplier: 1,
            constant: configuration.position == .Left ? -panelWidthOpened() : panelWidthOpened() )
        
        viewController.view.addConstraint(positionConstraint)
        
        viewController.view.addConstraint(widthConstraint)
        
        self.didMove(toParentViewController: viewController)
        
        if configuration.isModal {
            addModalOverlayToViewController(viewController: viewController)
        }
    }
    
    /**
    Add the viewController for the content.
    
    - parameter viewController: UIViewController that will added as the content
    */
    func addContentViewController(viewController: UIViewController) {
        
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        viewController.willMove(toParentViewController: self)
        self.addChildViewController(viewController)
        contentView.addSubview(viewController.view)
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|",
                                                                  options: NSLayoutFormatOptions(rawValue: 0),
                                                                  metrics: nil,
                                                                  views: ["view": viewController.view]))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|",
                                                                  options: NSLayoutFormatOptions(rawValue: 0),
                                                                  metrics: nil,
                                                                  views: ["view": viewController.view]))
        
        viewController.didMove(toParentViewController: self)
    }
    
    /**
    Open the panel.
    The width of the panel will not be changed, only the position.
    */
    func openPanel() {
        
        currentState = .Opened
        
        positionConstraint.constant = 0
        
        self.view.superview!.setNeedsUpdateConstraints()
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.view.superview!.layoutIfNeeded()
            
            self.overlay.alpha = 0.4
        })
        
        draggerView.displayImageForState(state: currentState, animated: true)
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
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.view.superview!.layoutIfNeeded()
            
            self.overlay.alpha = 0.0
        })
        
        draggerView.displayImageForState(state: currentState, animated: true)
    }
    
    //TODO: When the panel is opened and the devices rotates to another orientation, then the width is not correct.
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        // call openPanel() again to set the correct width according to the changed width of the parent view
        if currentState == .Opened {
            openPanel()
        }
    }

    /**
    Add a transparent (black color with alpha) view.
    This is used when the panel is opened.
    - parameter viewController: UIViewController that is used to insert the gray view
    */
    private func addModalOverlayToViewController(viewController: UIViewController) {
        
        overlay.backgroundColor = UIColor.black
        overlay.alpha = 0.0
        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.addTarget(self, action: #selector(SliderViewController.pressedBackground), for: UIControlEvents.touchUpInside)
        
        viewController.view.insertSubview(overlay, belowSubview: self.view)
        viewController.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|",
                                                                          options: NSLayoutFormatOptions(rawValue: 0),
                                                                          metrics: nil,
                                                                          views: ["view": overlay]))
        viewController.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|",
                                                                          options: NSLayoutFormatOptions(rawValue: 0),
                                                                          metrics: nil,
                                                                          views: ["view": overlay]))
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
    - parameter recognizer: UITapGestureRecognizer
    */
    @objc private func tapRecognized(_ recognizer: UITapGestureRecognizer) {
        
        if recognizer.state == .ended {
            
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
    - parameter recognizer: UIPanGestureRecognizer
    */
    @objc private func panRecognized(_ recognizer: UIPanGestureRecognizer) {
        
        let velocity = recognizer.velocity(in: self.view)

        let position = recognizer.translation(in: self.view.superview!)
        
        let location: (CGFloat) = {
            if self.configuration.position == .Right {
                return self.view.superview!.bounds.size.width - recognizer.location(in: self.view.superview!).x
            }
            else {
                return recognizer.location(in: self.view.superview!).x
            }
        }()
        
        if recognizer.state == .changed {

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
            
        else if recognizer.state == .ended {

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
    
    - returns: Width of the panel when it is opened
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
