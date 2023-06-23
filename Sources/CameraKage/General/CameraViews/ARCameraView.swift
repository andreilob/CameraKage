//
//  ARCameraView.swift
//  
//
//  Created by Lobont Andrei on 20.06.2023.
//

import UIKit

/// Camera view containing an AR camera capable of loading face masks over people and recording content.
public class ARCameraView: UIView {
    private var arCamera: ARCameraInterface
    private let delegatesManager: DelegatesManagerProtocol
    
    /// Determines if the AR camera session is running.
    public var isSessionRunning: Bool { arCamera.isSessionRunning }
    
    /// Determines if the AR camera has a video recording in progress.
    public var isRecording: Bool { arCamera.isRecording }
    
    init(arCamera: ARCameraInterface,
         delegatesManager: DelegatesManagerProtocol = DelegatesManager()) {
        self.arCamera = arCamera
        self.delegatesManager = delegatesManager
        super.init(frame: .zero)
        self.arCamera.delegate = self
        self.arCamera.embedPreview(inView: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Coder not implemented")
    }
    
    /**
     Register a delegate to receive notifications regarding the camera session.
     
     - parameter delegate: The object that will receive the notifications.
     */
    public func registerDelegate(_ delegate: any ARCameraViewDelegate) {
        delegatesManager.registerDelegate(delegate)
    }
    
    /**
     Unregisters a delegate from receiving notifications.
     
     - parameter delegate: The object to be removed.
     */
    public func unregisterDelegate(_ delegate: any ARCameraViewDelegate) {
        delegatesManager.unregisterDelegate(delegate)
    }
    
    /**
     Starts the AR camera session.
     */
    public func startCamera() {
        arCamera.startCamera()
    }
    
    /**
     Stops the AR camera session.
     */
    public func stopCamera() {
        arCamera.stopCamera()
    }
    
    /**
     Captures a photo from the AR camera. Resulted photo will be delivered via `ARCameraDelegate`.
     */
    public func capturePhoto() {
        arCamera.capturePhoto()
    }
    
    /**
     Starts a video recording for the camera. `ARCameraDelegate` sends a notification when the recording has started.
     */
    public func startVideoRecording() {
        arCamera.startVideoRecording()
    }
    
    /**
     Stops the video recording. `ARCameraDelegate` sends a notification containing the URL of the video file.
     */
    public func stopVideoRecording() {
        arCamera.stopVideoRecording()
    }
    
    /**
     Loads a 3D face mask from the bundle of the application.
     
     - parameter name: The name of the file.
     - parameter fileType: The extension of the file. (don't put `.` in front of the file type)
     */
    public func loadARMask(name: String, fileType: String) {
        arCamera.loadARMask(name: name, fileType: fileType)
    }
    
    private func invokeDelegates(_ execute: @escaping (ARCameraViewDelegate) -> Void) {
        arCamera.delegateQueue.async { [weak self] in
            guard let self else { return }
            self.delegatesManager.invokeDelegates { delegate in
                guard let delegate = delegate as? ARCameraViewDelegate else { return }
                execute(delegate)
            }
        }
    }
}

// MARK: - ARCameraDelegate
extension ARCameraView: ARCameraDelegate {
    func arCamera(didCapturePhotoWithData data: Data) {
        invokeDelegates { $0.arCamera(didCapturePhotoWithData: data) }
    }
    
    func arCamera(didBeginRecordingVideoAtURL url: URL) {
        invokeDelegates { $0.arCamera(didBeginRecordingVideoAtURL: url) }
    }
    
    func arCamera(didRecordVideoAtURL url: URL) {
        invokeDelegates { $0.arCamera(didRecordVideoAtURL: url) }
    }
    
    func arCamera(didFailWithError error: ARCameraError) {
        invokeDelegates { $0.arCamera(didFailWithError: error) }
    }
    
    func arCameraWasInterrupted() {
        invokeDelegates { $0.arCameraWasInterrupted() }
    }
    
    func arCameraInterruptionEnded() {
        invokeDelegates { $0.arCameraInterruptionEnded() }
    }
}
