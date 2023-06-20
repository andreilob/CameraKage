//
//  InteractableCameraView.swift
//  
//
//  Created by Lobont Andrei on 12.06.2023.
//

import UIKit

/// Base camera view containing camera displaying and basic features used on all types of cameras.
public class InteractableCameraView: SessionCameraView {
    private var interactableCamera: InteractableCameraInterface
    private var lastZoomFactor: CGFloat = 1.0
    private lazy var pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinch(_:)))
    
    init(interactableCamera: InteractableCameraInterface) {
        self.interactableCamera = interactableCamera
        super.init(sessionCamera: interactableCamera)
        if interactableCamera.isZoomAllowed {
            addGestureRecognizer(pinchGestureRecognizer)
        }
    }
    
    init(interactableCamera: InteractableCameraInterface,
         sessionQueue: DispatchQueue) {
        self.interactableCamera = interactableCamera
        super.init(sessionCamera: interactableCamera, sessionQueue: sessionQueue)
        if interactableCamera.isZoomAllowed {
            addGestureRecognizer(pinchGestureRecognizer)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("Coder not usable.")
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
                self.interactableCamera.stopCameraSession()
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    self.interactableCamera.removePreviewLayer()
                }
                try self.interactableCamera.flipCamera()
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    self.interactableCamera.embedPreviewLayer(in: self.layer)
                    self.layoutSubviews()
                }
                self.interactableCamera.startCameraSession()
            } catch let error as CameraError {
                self.invokeDelegates { $0.cameraDidEncounterError(error: error) }
            } catch {
                self.invokeDelegates { $0.cameraDidEncounterError(error: .cameraComponentError(reason: .failedToLockDevice)) }
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
                try self.interactableCamera.focus(with: focusMode,
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
    
    private func invokeDelegates(_ execute: @escaping (InteractableCameraDelegate) -> Void) {
        interactableCamera.delegateQueue.async { [weak self] in
            guard let self else { return }
            self.delegatesManager.invokeDelegates { delegate in
                guard let delegate = delegate as? InteractableCameraDelegate else { return }
                execute(delegate)
            }
        }
    }
    
    @objc private func pinch(_ pinch: UIPinchGestureRecognizer) {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            let newScaleFactor = self.interactableCamera.minMaxZoom(pinch.scale * self.lastZoomFactor)
            do {
                switch pinch.state {
                case .changed:
                    try self.interactableCamera.zoom(atScale: newScaleFactor)
                    self.invokeDelegates { $0.cameraDidZoom(atScale: newScaleFactor,
                                                            outOfMaximumScale: self.interactableCamera.maxZoomScale) }
                case .ended:
                    self.lastZoomFactor = self.interactableCamera.minMaxZoom(newScaleFactor)
                    try self.interactableCamera.zoom(atScale: self.lastZoomFactor)
                    self.invokeDelegates { $0.cameraDidZoom(atScale: self.lastZoomFactor,
                                                            outOfMaximumScale: self.interactableCamera.maxZoomScale) }
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
