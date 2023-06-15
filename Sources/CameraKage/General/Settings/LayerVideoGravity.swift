//
//  LayerVideoGravity.swift
//  
//
//  Created by Lobont Andrei on 14.06.2023.
//

import Foundation

public enum LayerVideoGravity {
    /// Preserve aspect ratio, fit within layer bounds.
    case resizeAspect
    
    /// Preserve aspect ratio, fill layer bounds.
    case resizeAspectFill

    /// Stretch to fill layer bounds.
    case resize
}
