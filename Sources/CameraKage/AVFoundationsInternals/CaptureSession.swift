//
//  CaptureSession.swift
//  
//
//  Created by Lobont Andrei on 05.06.2023.
//

import AVFoundation

class CaptureSession: AVCaptureMultiCamSession {
    func cleanupSession() {
        defer {
            commitConfiguration()
        }
        beginConfiguration()
        
        outputs.forEach { removeOutput($0) }
        inputs.forEach { removeInput($0) }
        connections.forEach { removeConnection($0) }
    }
}
