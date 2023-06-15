//
//  PhotoQualityPrioritizationMode.swift
//  
//
//  Created by Lobont Andrei on 14.06.2023.
//

import Foundation

public enum PhotoQualityPrioritizationMode {
    /// Speed of the photo delivery will be prioritized, even at the expense of photo quality
    case speed
    
    /// Speed and quality of the photo will be equally prioritized.
    case balanced
    
    /// Quality of the photo will be prioritized, even at the expense of the delivery time of the photo.
    case quality
}
