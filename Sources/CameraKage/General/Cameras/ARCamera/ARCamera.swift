//
//  ARCamera.swift
//  
//
//  Created by Lobont Andrei on 20.06.2023.
//

import UIKit
import AVFoundation

class ARCamera: ARCameraInterface {
    private var arPreviewView: ARPreviewer
    private var assetWriter: AssetWriterInterface
    private let options: ARCameraComponentParsedOptions
    
    var isSessionRunning: Bool { arPreviewView.isSessionRunning }
    var isRecording: Bool { assetWriter.isRecording }
    var delegateQueue: DispatchQueue { options.delegateQeueue }
    
    weak var delegate: ARCameraDelegate?
    
    init(arPreviewView: ARPreviewer,
         assetWriter: AssetWriterInterface,
         options: ARCameraComponentParsedOptions) {
        self.arPreviewView = arPreviewView
        self.assetWriter = assetWriter
        self.options = options
        self.arPreviewView.sessionDelegate = self
        self.assetWriter.delegate = self
    }
    
    func startCamera() {
        arPreviewView.startCameraSession()
    }
    
    func stopCamera() {
        arPreviewView.stopCameraSession()
        assetWriter.stopVideoRecording()
    }
    
    func resetCamera() {
        arPreviewView.resetCamera()
    }
    
    func loadARMask(name: String, fileType: String){
        arPreviewView.loadARMask(name: name, fileType: fileType)
    }
    
    func capturePhoto() {
        assetWriter.capturePhoto()
    }
    
    func startVideoRecording() {
        assetWriter.startVideoRecording()
    }
    
    func stopVideoRecording() {
        assetWriter.stopVideoRecording()
    }
    
    func embedPreview(inView view: UIView) {
        arPreviewView.embedPreview(inView: view)
    }
}

// MARK: - ARAssetWriterDelegate
extension ARCamera: ARAssetWriterDelegate {
    func assetWriter(didCapturePhotoWithData data: Data) {
        delegate?.arCamera(didCapturePhotoWithData: data)
    }
    
    func assetWriter(didBeginRecordingVideoAtURL url: URL) {
        delegate?.arCamera(didBeginRecordingVideoAtURL: url)
    }
    
    func assetWriter(didRecordVideoAtURL url: URL) {
        delegate?.arCamera(didRecordVideoAtURL: url)
    }
    
    func assetWriter(didEncounterError error: ARCameraError) {
        delegate?.arCamera(didFailWithError: error)
    }
}

// MARK: - ARSessionDelegate
extension ARCamera: ARSessionDelegate {
    func arSession(didOutputAudioBuffer audioBuffer: CMSampleBuffer) {
        assetWriter.appendAudioBuffer(audioBuffer)
    }
    
    func arSession(didFailWithError error: ARCameraError) {
        delegate?.arCamera(didFailWithError: error)
    }
    
    func arSessionWasInterrupted() {
        delegate?.arCameraWasInterrupted()
    }
    
    func arSessionInterruptionEnded() {
        delegate?.arCameraInterruptionEnded()
    }
}
