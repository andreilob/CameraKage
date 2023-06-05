//
//  FlashMode.swift
//  
//
//  Created by Lobont Andrei on 04.06.2023.
//

import Foundation

/// Flash mode used when capturing content.
public enum FlashMode {
    /// Case `.on` will use flash when capturing content.
    case on
    
    /// Case `.off` will not use flash when capturing content.
    case off
    
    /// Case `.auto` will let the camera to decide wether flash is needed or not, depending on the surrounding light.
    case auto
}
