//
//  Resolution.swift
//  
//
//  Created by Lobont Andrei on 04.07.2023.
//

import Foundation

public enum Resolution {
    case R720p
    case R1080p
    
    var width: CGFloat {
        switch self {
        case .R720p: return 720
        case .R1080p: return 1080
        }
    }
    
    var height: CGFloat {
        switch self {
        case .R720p: return 1280
        case .R1080p: return 1920
        }
    }
}
