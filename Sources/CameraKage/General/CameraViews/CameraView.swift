//
//  CameraView.swift
//  
//
//  Created by Lobont Andrei on 13.06.2023.
//

import Foundation

/// View capable of both video recordings and photo captures.
public class CameraView: InteractableCameraView {
    private var camera: CameraInterface
    
    /// Determines if the camera has a video recording in progress.
    public var isRecording: Bool { camera.isRecording }
    
    init(camera: CameraInterface) {
        self.camera = camera
        super.init(interactableCamera: camera)
        setupPhotoCapturer()
        setupVideoCapturer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Coder not usable.")
    }
    
    /**
     Register a delegate to receive notifications regarding the camera session.
     
     - parameter delegate: The object that will receive the notifications.
     */
    public func registerDelegate(_ delegate: any CameraDelegate) {
        super.registerDelegate(delegate)
    }
    
    /**
     Unregisters a delegate from receiving notifications.
     
     - parameter delegate: The object to be removed.
     */
    public func unregisterDelegate(_ delegate: any CameraDelegate) {
        super.unregisterDelegate(delegate)
    }
    
    /**
     Captures a photo from the camera. Resulted photo will be delivered via `PhotoCameraDelegate`.
     
     - parameter flashOption: Indicates what flash option should be used when capturing the photo. Default is `.off`.
     - parameter redEyeCorrection: Determines if red eye correction should be applied or not. Default is `true`.
     */
    public func capturePhoto(flashMode: FlashMode = .off,
                             redEyeCorrection: Bool = true) {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            self.camera.capturePhoto(flashMode, redEyeCorrection: redEyeCorrection)
        }
    }
    
    /**
     Starts a video recording for the camera. `VideoCameraDelegate` sends a notification when the recording has started.
     
     - parameter flashOption: Indicates what flash option should be used for the video recording. Default is `.off`.
     
     - important: Front camera dosen't support video recordings with flash mode `.on`.
     */
    public func startVideoRecording(flashOption: FlashMode = .off) {
        sessionQueue.async { [weak self] in
            guard let self, !self.isRecording else { return }
            self.camera.startVideoRecording()
            do {
                try self.camera.configureFlash(flashOption)
            } catch let error as CameraError {
                self.invokeDelegates { $0.cameraDidEncounterError(error: error) }
            } catch {
                self.invokeDelegates { $0.cameraDidEncounterError(error: .cameraComponentError(reason: .torchModeNotSupported)) }
            }
        }
    }
    
    /**
     Stops the video recording. `VideoCameraDelegate` sends a notification containing the URL of the video file.
     */
    public func stopVideoRecording() {
        sessionQueue.async { [weak self] in
            guard let self, self.isRecording else { return }
            self.camera.stopVideoRecording()
            do {
                try self.camera.configureFlash(.off)
            } catch let error as CameraError {
                self.invokeDelegates { $0.cameraDidEncounterError(error: error) }
            } catch {
                self.invokeDelegates { $0.cameraDidEncounterError(error: .cameraComponentError(reason: .torchModeNotSupported)) }
            }
        }
    }
    
    private func setupVideoCapturer() {
        camera.onMovieCaptureStart = { [weak self] url in
            guard let self else { return }
            self.invokeDelegates { $0.cameraDidStartVideoRecording(atFileURL: url) }
        }
        camera.onMovieCaptureSuccess = { [weak self] url in
            guard let self else { return }
            self.invokeDelegates { $0.cameraDidFinishVideoRecording(atFileURL: url) }
        }
        camera.onMovieCaptureError = { [weak self] error in
            guard let self else { return }
            self.invokeDelegates { $0.cameraDidEncounterError(error: error) }
        }
    }
    
    private func setupPhotoCapturer() {
        camera.onPhotoCaptureSuccess = { [weak self] data in
            guard let self else { return }
            self.invokeDelegates { $0.cameraDidCapturePhoto(withData: data) }
        }
        camera.onPhotoCaptureError = { [weak self] error in
            guard let self else { return }
            self.invokeDelegates { $0.cameraDidEncounterError(error: error) }
        }
    }
    
    private func invokeDelegates(_ execute: @escaping (any CameraDelegate) -> Void) {
        camera.delegateQueue.async { [weak self] in
            guard let self else { return }
            self.delegatesManager.invokeDelegates { delegate in
                guard let delegate = delegate as? (any CameraDelegate) else { return }
                execute(delegate)
            }
        }
    }
}
