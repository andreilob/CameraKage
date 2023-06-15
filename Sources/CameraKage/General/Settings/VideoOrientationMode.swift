//
//  VideoOrientationMode.swift
//  
//
//  Created by Lobont Andrei on 14.06.2023.
//

import Foundation

public enum VideoOrientationMode {
    /// Indicates that video should be oriented vertically, home button on the bottom.
    case portrait

    /// Indicates that video should be oriented vertically, home button on the top.
    case portraitUpsideDown

    /// Indicates that video should be oriented horizontally, home button on the right.
    case landscapeRight
    
    /// Indicates that video should be oriented horizontally, home button on the left.
    case landscapeLeft 
}
