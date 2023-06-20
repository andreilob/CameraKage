//
//  SessionCamera.swift
//  
//
//  Created by Lobont Andrei on 16.06.2023.
//

import Foundation
import QuartzCore.CALayer

class SessionCamera: SessionCameraInterface {
    var session: Session
    let videoInput: VideoInput
    let videoLayer: VideoLayer
    let options: CameraComponentParsedOptions
    
    var delegateQueue: DispatchQueue { options.delegateQeueue }
    var isSessionRunning: Bool { session.isRunning }
    
    init(session: Session,
         videoInput: VideoInput,
         videoLayer: VideoLayer,
         options: CameraComponentParsedOptions) {
        self.session = session
        self.videoInput = videoInput
        self.videoLayer = videoLayer
        self.options = options
    }
    
    func startCameraSession() {
        session.addObservers()
        session.startSession()
    }
    
    func stopCameraSession() {
        session.stopSession()
        session.removeObservers()
    }
    
    func resumeCameraSession() {
        session.startSession()
    }
    
    func setSessionDelegate(_ delegate: SessionDelegate) {
        session.delegate = delegate
    }
    
    func configureFlash(_ flashMode: FlashMode) throws {
        do {
            try videoInput.configureFlash(flashMode)
        } catch let error {
            throw error
        }
    }
    
    func embedPreviewLayer(in layer: CALayer) {
        videoLayer.embedPreviewLayer(in: layer)
    }
    
    func setPreviewLayerFrame(_ frame: CGRect) {
        videoLayer.setPreviewLayerFrame(frame)
    }
    
    func removePreviewLayer() {
        videoLayer.removeFromSuperlayer()
    }
}
