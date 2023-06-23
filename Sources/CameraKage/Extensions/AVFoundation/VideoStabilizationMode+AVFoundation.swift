//
//  VideoStabilizationMode+AVFoundation.swift
//  
//
//  Created by Lobont Andrei on 14.06.2023.
//

import AVFoundation

extension VideoStabilizationMode {
    var avVideoStabilizationMode: AVCaptureVideoStabilizationMode {
        switch self {
        case .off: return .off
        case .standard: return .standard
        case .cinematic: return .cinematic
        case .cinematicExtended: return .cinematicExtended
        case .auto: return .auto
        }
    }
}
