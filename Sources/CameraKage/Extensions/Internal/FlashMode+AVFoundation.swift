//
//  FlashMode+AVFoundation.swift
//  
//
//  Created by Lobont Andrei on 04.06.2023.
//

import AVFoundation

extension FlashMode {
    var avFlashOption: AVCaptureDevice.FlashMode {
        switch self {
        case .on: return .on
        case .off: return .off
        case .auto: return .auto
        }
    }
}
