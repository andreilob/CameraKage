//
//  ARSessionDelegate.swift
//  
//
//  Created by Lobont Andrei on 21.06.2023.
//

import AVFoundation

protocol ARSessionDelegate: AnyObject {
    func arSession(didOutputAudioBuffer audioBuffer: CMSampleBuffer)
    func arSession(didFailWithError error: ARCameraError)
    func arSessionWasInterrupted()
    func arSessionInterruptionEnded()
}
