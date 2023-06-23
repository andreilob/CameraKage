//
//  VideoOrientationMode+AVFoundation.swift
//  
//
//  Created by Lobont Andrei on 14.06.2023.
//

import AVFoundation

extension VideoOrientationMode {
    var avVideoOrientationMode: AVCaptureVideoOrientation {
        switch self {
        case .portrait: return .portrait
        case .portraitUpsideDown: return .portraitUpsideDown
        case .landscapeRight: return .landscapeRight
        case .landscapeLeft: return .landscapeLeft
        }
    }
}
