//
//  AssetWriterInterface.swift
//  
//
//  Created by Lobont Andrei on 21.06.2023.
//

import AVFoundation

protocol AssetWriterInterface {
    var isRecording: Bool { get }
    var delegate: ARAssetWriterDelegate? { get set }
    
    func capturePhoto()
    func startVideoRecording()
    func stopVideoRecording()
    func appendAudioBuffer(_ buffer: CMSampleBuffer)
}
