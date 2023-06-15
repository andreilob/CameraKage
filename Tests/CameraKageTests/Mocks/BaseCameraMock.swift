//
//  BaseCameraMock.swift
//  
//
//  Created by Lobont Andrei on 15.06.2023.
//

import Foundation
import QuartzCore.CALayer
@testable import CameraKage

class BaseCameraMock: BaseCameraInterface {
    private let videoInput: VideoInput
    private let options: CameraComponentParsedOptions
    
    var session: Session
    let videoLayer: VideoLayer
    var isZoomAllowed: Bool { options.pinchToZoomEnabled }
    var delegateQueue: DispatchQueue { options.delegateQeueue }
    var isSessionRunning: Bool { session.isRunning }
    var maxZoomScale: CGFloat { options.maximumZoomScale }
    
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
    
    func flipCamera() throws {
        do {
            try videoInput.flip()
        } catch let error {
            throw error
        }
    }
    
    func focus(with focusMode: FocusMode,
               exposureMode: ExposureMode,
               at devicePoint: CGPoint,
               monitorSubjectAreaChange: Bool) throws {
        do {
            let point = videoLayer.captureDevicePointConverted(fromLayerPoint: devicePoint)
            try videoInput.focus(focusMode: focusMode,
                                 exposureMode: exposureMode,
                                 point: point,
                                 monitorSubjectAreaChange: monitorSubjectAreaChange)
        } catch let error {
            throw error
        }
    }
    
    func zoom(atScale scale: CGFloat) throws {
        do {
            try videoInput.zoom(atScale: scale)
        } catch let error {
            throw error
        }
    }
    
    func minMaxZoom(_ factor: CGFloat) -> CGFloat {
        videoInput.minMaxZoom(factor, options: options)
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
