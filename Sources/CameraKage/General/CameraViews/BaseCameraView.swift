//
//  BaseCameraView.swift
//  
//
//  Created by Lobont Andrei on 12.06.2023.
//

import UIKit

/// Base camera view containing camera displaying and basic features used on all types of cameras.
public class BaseCameraView: UIView {
    private var baseCamera: BaseCameraInterface
    private var lastZoomFactor: CGFloat = 1.0
    private lazy var pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinch(_:)))
    
    let sessionQueue: DispatchQueue
    let delegatesManager: DelegatesManagerProtocol
    
    /// Determines if the camera session is running.
    public var isSessionRunning: Bool { baseCamera.isSessionRunning }
    
    init(baseCamera: BaseCameraInterface,
         delegatesManager: DelegatesManagerProtocol = DelegatesManager(),
         sessionQueue: DispatchQueue = DispatchQueue(label: "LA.cameraKage.sessionQueue")) {
        self.baseCamera = baseCamera
        self.delegatesManager = delegatesManager
        self.sessionQueue = sessionQueue
        super.init(frame: .zero)
        baseCamera.setSessionDelegate(self)
        baseCamera.embedPreviewLayer(in: layer)
        if baseCamera.isZoomAllowed {
            addGestureRecognizer(pinchGestureRecognizer)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("Coder not usable.")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        baseCamera.setPreviewLayerFrame(frame)
    }
    
    /**
     Starts the camera session..
     */
    public func startCamera() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            self.baseCamera.startCameraSession()
        }
    }
    
    /**
     Stops the camera session.
     */
    public func stopCamera() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            self.baseCamera.stopCameraSession()
        }
    }
    
    /**
     Flips the camera from back to front and vice-versa.
     
     - important: Camera can't be flipped while recording a video. Session is restarted when flipping the camera.
     */
    public func flipCamera() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            do {
                self.lastZoomFactor = 1.0
                self.baseCamera.stopCameraSession()
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    self.baseCamera.removePreviewLayer()
                }
                try self.baseCamera.flipCamera()
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    self.baseCamera.embedPreviewLayer(in: self.layer)
                    self.layoutSubviews()
                }
                self.baseCamera.startCameraSession()
            } catch let error as CameraError {
                invokeDelegates { $0.cameraDidEncounterError(error: error) }
            } catch {
                invokeDelegates { $0.cameraDidEncounterError(error: .cameraComponentError(reason: .failedToLockDevice)) }
            }
        }
    }
    
    /**
     Adjusts the focus and the exposure of the camera.
     
     - parameter focusMode: Focus mode of the camera. Default is `.autoFocus`.
     - parameter exposureMode: Exposure mode of the camera. Default is `.autoExpose`.
     - parameter devicePoint: The point of the camera where the focus should be switched to.
     - parameter monitorSubjectAreaChange: If set `true`, it registers the camera to receive notifications about area changes for the user to re-focus if needed. Default is `true`.
     */
    public func focus(with focusMode: FocusMode = .autoFocus,
                      exposureMode: ExposureMode = .autoExpose,
                      at devicePoint: CGPoint,
                      monitorSubjectAreaChange: Bool = true) {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            do {
                try self.baseCamera.focus(with: focusMode,
                                          exposureMode: exposureMode,
                                          at: devicePoint,
                                          monitorSubjectAreaChange: monitorSubjectAreaChange)
            } catch let error as CameraError {
                self.invokeDelegates { $0.cameraDidEncounterError(error: error) }
            } catch {
                self.invokeDelegates { $0.cameraDidEncounterError(error: .cameraComponentError(reason: .failedToLockDevice)) }
            }
        }
    }
    
    func registerDelegate(_ delegate: any BaseCameraDelegate) {
        delegatesManager.registerDelegate(delegate)
    }
    
    func unregisterDelegate(_ delegate: any BaseCameraDelegate) {
        delegatesManager.unregisterDelegate(delegate)
    }
    
    private func invokeDelegates(_ execute: @escaping (BaseCameraDelegate) -> Void) {
        baseCamera.delegateQueue.async { [weak self] in
            guard let self else { return }
            self.delegatesManager.invokeDelegates { delegate in
                guard let delegate = delegate as? BaseCameraDelegate else { return }
                execute(delegate)
            }
        }
    }
    
    @objc private func pinch(_ pinch: UIPinchGestureRecognizer) {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            let newScaleFactor = self.baseCamera.minMaxZoom(pinch.scale * self.lastZoomFactor)
            do {
                switch pinch.state {
                case .changed:
                    try self.baseCamera.zoom(atScale: newScaleFactor)
                    self.invokeDelegates { $0.cameraDidZoom(atScale: newScaleFactor,
                                                            outOfMaximumScale: self.baseCamera.maxZoomScale) }
                case .ended:
                    self.lastZoomFactor = self.baseCamera.minMaxZoom(newScaleFactor)
                    try self.baseCamera.zoom(atScale: self.lastZoomFactor)
                    self.invokeDelegates { $0.cameraDidZoom(atScale: self.lastZoomFactor,
                                                            outOfMaximumScale: self.baseCamera.maxZoomScale) }
                default:
                    break
                }
            } catch let error as CameraError {
                self.invokeDelegates { $0.cameraDidEncounterError(error: error) }
            } catch {
                self.invokeDelegates { $0.cameraDidEncounterError(error: .cameraComponentError(reason: .failedToLockDevice)) }
            }
        }
    }
}

// MARK: - SessionDelegate
extension BaseCameraView: SessionDelegate {
    func session(_ sessionComposer: Session, didReceiveRuntimeError error: CameraError, shouldRestartCamera restart: Bool) {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            self.baseCamera.resumeCameraSession()
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
