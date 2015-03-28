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
    
    /// Width of the dragger (tappable and draggable area).
    var draggerWidth = 30.0
    /// When set this image will be used for opened and closed state.
    var draggerImage: UIImage?
    /// Set explicit image when the panel is opened.
    var draggerImageOpen: UIImage?
    /// Set explicit image when panel is closed.
    var draggerImageClose: UIImage?
    /// Define how the image should be scaled.
    var draggerContentMode = UIViewContentMode.ScaleAspectFit
    
    /// Maximum width when opened. When not set 1/3 of the width of the superview of the panel will be used.
    var widthOpened: CGFloat?
    /// Maxmimum width when closed. Default is 0.
    var widthClosed = CGFloat(0)
    
    /// When true the panel can be moved over the widthOpened size.
    var expandable = true
    
    /// Add shadow to content view
    var shadowEnabled = true
    
    var isModal = true
}