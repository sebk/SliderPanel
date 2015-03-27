//
//  SliderConfiguration.swift
//  SliderPanel
//
//  Created by seb on 27.03.15.
//  Copyright (c) 2015 seb. All rights reserved.
//

import Foundation
import UIKit

enum SliderPosition {
    case Left
    case Right
}

class SliderConfiguration {
    
    var position = SliderPosition.Left
    
    var contentBackgroundColor = UIColor.clearColor()
    var draggerBackgroundColor = UIColor.clearColor()
    
    var draggerWidth = 30.0
    var draggerImage: UIImage?
    var draggerImageOpen: UIImage?
    var draggerImageClose: UIImage?
    var draggerContentMode = UIViewContentMode.ScaleAspectFit
    
    var widthOpened: CGFloat? //when not set 1/3 of the width of the superview of the panel will be used
    var widthClosed = CGFloat(0)
    
    var enableShadow = true 
    
}