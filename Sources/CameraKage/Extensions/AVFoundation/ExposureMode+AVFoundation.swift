//
//  ExposureMode+AVFoundation.swift
//  
//
//  Created by Lobont Andrei on 04.06.2023.
//

import AVFoundation

extension ExposureMode {
    var avExposureOption: AVCaptureDevice.ExposureMode {
        switch self {
        case .locked: return .locked
        case .autoExpose: return .autoExpose
        case .continuousAutoExposure: return .autoExpose
        }
    }
}
