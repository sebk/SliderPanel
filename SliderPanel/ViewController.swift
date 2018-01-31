//
//  ViewController.swift
//  SliderPanel
//
//  Created by seb on 26.03.15.
//  Copyright (c) 2015 seb. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set configuration of the slider
        let configLeft = SliderConfiguration()
        configLeft.draggerImageOpen = UIImage(named: "PanelOpen")
        configLeft.draggerImageClose = UIImage(named: "PanelClose")
        configLeft.expandable = true
        configLeft.stayExpanded = true
        
        let configRight = SliderConfiguration()
        configRight.position = .Right
        configRight.draggerImageOpen = UIImage(named: "PanelOpen")
        configRight.draggerImageClose = UIImage(named: "PanelClose")
        configRight.expandable = true
        //configRight.stayExpanded = true
        
        // create and add the slider
        let leftSlider = SliderViewController(configuration: configLeft)
        leftSlider.addSliderToViewController(viewController: self)
        
        let rightSlider = SliderViewController(configuration: configRight)
        rightSlider.addSliderToViewController(viewController: self)
        
        
        
        //create and add a test content
        let leftContent = TestTableViewController()
        leftContent.uiTestIdentifier = "Content Table left"
        let rightContent = TestTableViewController()
        rightContent.uiTestIdentifier = "Content Table right"
        leftSlider.addContentViewController(viewController: leftContent)
        rightSlider.addContentViewController(viewController: rightContent)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

