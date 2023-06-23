//
//  FocusMode+AVFoundation.swift
//  
//
//  Created by Lobont Andrei on 04.06.2023.
//

import AVFoundation

extension FocusMode {
    var avFocusOption: AVCaptureDevice.FocusMode {
        switch self {
        case .locked: return .locked
        case .autoFocus: return .autoFocus
        case .continuousAutoFocus: return .continuousAutoFocus
        }
    }
}
