//
//  SessionCameraView.swift
//  
//
//  Created by Lobont Andrei on 18.06.2023.
//

import UIKit

public class SessionCameraView: UIView {
    private var sessionCamera: SessionCameraInterface
    
    let sessionQueue: DispatchQueue
    let delegatesManager: DelegatesManagerProtocol
    
    /// Determines if the camera session is running.
    public var isSessionRunning: Bool { sessionCamera.isSessionRunning }
    
    init(sessionCamera: SessionCameraInterface,
         delegatesManager: DelegatesManagerProtocol = DelegatesManager(),
         sessionQueue: DispatchQueue = DispatchQueue(label: "LA.cameraKage.sessionQueue")) {
        self.sessionCamera = sessionCamera
        self.delegatesManager = delegatesManager
        self.sessionQueue = sessionQueue
        super.init(frame: .zero)
        sessionCamera.setSessionDelegate(self)
        sessionCamera.embedPreviewLayer(in: layer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Coder not usable.")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        sessionCamera.setPreviewLayerFrame(frame)
    }
    
    /**
     Starts the camera session..
     */
    public func startCamera() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            self.sessionCamera.startCameraSession()
        }
    }
    
    /**
     Stops the camera session.
     */
    public func stopCamera() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            self.sessionCamera.stopCameraSession()
        }
    }
    
    func registerDelegate(_ delegate: any SessionCameraDelegate) {
        delegatesManager.registerDelegate(delegate)
    }
    
    func unregisterDelegate(_ delegate: any SessionCameraDelegate) {
        delegatesManager.unregisterDelegate(delegate)
    }
    
    private func invokeDelegates(_ execute: @escaping (SessionCameraDelegate) -> Void) {
        sessionCamera.delegateQueue.async { [weak self] in
            guard let self else { return }
            self.delegatesManager.invokeDelegates { delegate in
                guard let delegate = delegate as? SessionCameraDelegate else { return }
                execute(delegate)
            }
        }
    }
}

// MARK: - SessionDelegate
extension SessionCameraView: SessionDelegate {
    func session(_ sessionComposer: Session, didReceiveRuntimeError error: CameraError, shouldRestartCamera restart: Bool) {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            self.sessionCamera.resumeCameraSession()
        }
        invokeDelegates { $0.cameraDidEncounterError(error: error) }
    }
    
    func session(_ sessionComposer: Session, didReceiveSessionInterruption reason: SessionInterruptionReason) {
        invokeDelegates { $0.cameraDidReceiveSessionInterruption(withReason: reason) }
    }
    
    func sessionDidFinishSessionInterruption(_ sessionComposer: Session) {
        invokeDelegates { $0.cameraDidFinishSessionInterruption() }
    }
    
    func sessionDidStartCameraSession(_ sessionComposer: Session) {
        invokeDelegates { $0.cameraDidStartCameraSession() }
    }
    
    func sessionDidStopCameraSession(_ sessionComposer: Session) {
        invokeDelegates { $0.cameraDidStopCameraSession() }
    }
    
    func sessionDidChangeDeviceAreaOfInterest(_ sessionComposer: Session) {
        invokeDelegates { $0.cameraDidChangeDeviceAreaOfInterest() }
    }
}
