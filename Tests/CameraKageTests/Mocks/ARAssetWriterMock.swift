//
//  ARAssetWriterMock.swift
//  
//
//  Created by Lobont Andrei on 23.06.2023.
//

import AVFoundation
@testable import CameraKage

class ARAssetWriterMock: AssetWriterInterface {
    var isRecording: Bool = false
    
    weak var delegate: ARAssetWriterDelegate?
    
    func startVideoRecording() {
        isRecording = true
    }
    
    func stopVideoRecording() {
        isRecording = false
    }
    
    func capturePhoto() {}
    func appendAudioBuffer(_ buffer: CMSampleBuffer) {}
}
