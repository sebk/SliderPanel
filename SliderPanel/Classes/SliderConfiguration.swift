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
    
    var contentBackgroundColor = UIColor.clear
    var draggerBackgroundColor = UIColor.clear
    
    /// Width of the dragger (tappable and draggable area).
    var draggerWidth: CGFloat = 30.0
    /// When set this image will be used for opened and closed state.
    var draggerImage: UIImage?
    /// Set explicit image when the panel is opened.
    var draggerImageOpen: UIImage?
    /// Set explicit image when panel is closed.
    var draggerImageClose: UIImage?
    /// Define how the image should be scaled.
    var draggerContentMode = UIView.ContentMode.scaleAspectFit
    /// Width of the panel
    var width: CGFloat?
    /// When true the panel can be moved over the widthOpened size.
    var expandable = true
    /// Only when expandable is true. When true the slider will stay at the expanded size.
    var stayExpanded = false
    /// Add shadow to content view
    var shadowEnabled = true
    /// When true a gray overlay will be added when the slider is opened. 
    var isModal = true
}
