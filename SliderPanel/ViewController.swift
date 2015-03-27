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
        let config = SliderConfiguration()
        //config.draggerImage = UIImage(named: "Dragger")
        //config.draggerContentMode = UIViewContentMode.ScaleToFill
        config.draggerImageOpen = UIImage(named: "PanelOpen")
        config.draggerImageClose = UIImage(named: "PanelClose")
        //config.widthOpened = 50
        //config.widthClosed = 10
        
        
        // create and add the slider
        let slider = SliderViewController(configuration: config)
        slider.addSliderToViewController(self)
        
        //create and add a test content
        let tableVC = TestTableViewController()
        slider.addContentViewController(tableVC)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

