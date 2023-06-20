//
//  PhotoCameraView.swift
//  
//
//  Created by Lobont Andrei on 11.06.2023.
//

import Foundation

/// View capable only of photo captures.
public class PhotoCameraView: InteractableCameraView {
    private var photoCamera: PhotoCameraInterface
    
    init(photoCamera: PhotoCameraInterface) {
        self.photoCamera = photoCamera
        super.init(interactableCamera: photoCamera)
        setupPhotoCapturer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Coder not usable.")
    }
    
    /**
     Register a delegate to receive notifications regarding the camera session.
     
     - parameter delegate: The object that will receive the notifications.
     */
    public func registerDelegate(_ delegate: any PhotoCameraDelegate) {
        super.registerDelegate(delegate)
    }
    
    /**
     Unregisters a delegate from receiving notifications.
     
     - parameter delegate: The object to be removed.
     */
    public func unregisterDelegate(_ delegate: any PhotoCameraDelegate) {
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
            self.photoCamera.capturePhoto(flashMode, redEyeCorrection: redEyeCorrection)
        }
    }
    
    private func setupPhotoCapturer() {
        photoCamera.onPhotoCaptureSuccess = { [weak self] data in
            guard let self else { return }
            self.invokeDelegates { $0.cameraDidCapturePhoto(withData: data) }
        }
        photoCamera.onPhotoCaptureError = { [weak self] error in
            guard let self else { return }
            self.invokeDelegates { $0.cameraDidEncounterError(error: error) }
        }
    }
    
    private func invokeDelegates(_ execute: @escaping (any PhotoCameraDelegate) -> Void) {
        photoCamera.delegateQueue.async { [weak self] in
            guard let self else { return }
            self.delegatesManager.invokeDelegates { delegate in
                guard let delegate = delegate as? (any PhotoCameraDelegate) else { return }
                execute(delegate)
            }
        }
    }
}
