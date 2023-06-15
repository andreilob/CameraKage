//
//  VideoCameraView.swift
//  
//
//  Created by Lobont Andrei on 11.06.2023.
//

import Foundation

/// View capable only of video recordings.
public class VideoCameraView: BaseCameraView {
    private var videoCamera: VideoCameraInterface
    
    /// Determines if the camera has a video recording in progress.
    public var isRecording: Bool { videoCamera.isRecording }
    
    init(videoCamera: VideoCameraInterface) {
        self.videoCamera = videoCamera
        super.init(baseCamera: videoCamera)
        setupVideoCapturer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Coder not usable.")
    }
    
    /**
     Register a delegate to receive notifications regarding the camera session.
     
     - parameter delegate: The object that will receive the notifications.
     */
    public func registerDelegate(_ delegate: any VideoCameraDelegate) {
        super.registerDelegate(delegate)
    }
    
    /**
     Unregisters a delegate from receiving notifications.
     
     - parameter delegate: The object to be removed.
     */
    public func unregisterDelegate(_ delegate: any VideoCameraDelegate) {
        super.unregisterDelegate(delegate)
    }
    
    /**
     Starts a video recording for the camera. `VideoCameraDelegate` sends a notification when the recording has started.
     
     - parameter flashOption: Indicates what flash option should be used for the video recording. Default is `.off`.
     
     - important: Front camera dosen't support video recordings with flash mode `.on`.
     */
    public func startVideoRecording(flashOption: FlashMode = .off) {
        sessionQueue.async { [weak self] in
            guard let self, !self.isRecording else { return }
            self.videoCamera.startVideoRecording()
            do {
                try self.videoCamera.configureFlash(flashOption)
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
            self.videoCamera.stopVideoRecording()
            do {
                try self.videoCamera.configureFlash(.off)
            } catch let error as CameraError {
                self.invokeDelegates { $0.cameraDidEncounterError(error: error) }
            } catch {
                self.invokeDelegates { $0.cameraDidEncounterError(error: .cameraComponentError(reason: .torchModeNotSupported)) }
            }
        }
    }
    
    private func setupVideoCapturer() {
        videoCamera.onMovieCaptureStart = { [weak self] url in
            guard let self else { return }
            self.invokeDelegates { $0.cameraDidStartVideoRecording(atFileURL: url) }
        }
        videoCamera.onMovieCaptureSuccess = { [weak self] url in
            guard let self else { return }
            self.invokeDelegates { $0.cameraDidFinishVideoRecording(atFileURL: url) }
        }
        videoCamera.onMovieCaptureError = { [weak self] error in
            guard let self else { return }
            self.invokeDelegates { $0.cameraDidEncounterError(error: error) }
        }
    }
    
    private func invokeDelegates(_ execute: @escaping (any VideoCameraDelegate) -> Void) {
        videoCamera.delegateQueue.async { [weak self] in
            guard let self else { return }
            self.delegatesManager.invokeDelegates { delegate in
                guard let delegate = delegate as? (any VideoCameraDelegate) else { return }
                execute(delegate)
            }
        }
    }
}
