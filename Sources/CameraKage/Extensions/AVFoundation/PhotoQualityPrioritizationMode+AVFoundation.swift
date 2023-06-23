//
//  PhotoQualityPrioritizationMode+AVFoundation.swift
//  
//
//  Created by Lobont Andrei on 14.06.2023.
//

import AVFoundation

extension PhotoQualityPrioritizationMode {
    var avQualityPrioritizationMode: AVCapturePhotoOutput.QualityPrioritization {
        switch self {
        case .speed: return .speed
        case .balanced: return .balanced
        case .quality: return .quality
        }
    }
}
