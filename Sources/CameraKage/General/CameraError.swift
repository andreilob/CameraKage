//
//  CameraError.swift
//  CameraKage
//
//  Created by Lobont Andrei on 22.05.2023.
//

import AVFoundation

public enum CameraError: Error {
    public enum CameraComponentErrorReason {
        /// Specified video device couldn't be added to the session. *device might not be supported by the phone*
        case failedToConfigureVideoDevice
        
        /// Audio device couldn't be added to the session.
        case failedToConfigureAudioDevice
        
        /// Photo output couldn't be added to the session.
        case failedToAddPhotoOutput
        
        /// Movie output couldn't be added to the session.
        case failedToAddMovieOutput
        
        /// The preview layer wasn't connected to the camera session.
        case failedToAddPreviewLayer
        
        /// Couldn't lock video device for further configurations.
        case failedToLockDevice
        
        /// File manager couldn't remove a corrupted video file.
        case failedToRemoveFileManagerItem
        
        /// Camera was shutdown due to high pressure level.
        case pressureLevelShutdown
        
        /// Photo capture failure, error message received from the delegate will be passed.
        case failedToOutputPhoto(message: String?)
        
        /// Movie capture failure, error message received from the delegate will be passed.
        case failedToOutputMovie(message: String?)
    }
    
    public enum CameraSessionErrorReason {
        /// An internal error was encountered by the capture session. The specific AVError is passed.
        case runtimeError(AVError)
    }
    
    case cameraComponentError(reason: CameraComponentErrorReason)
    case cameraSessionError(reason: CameraSessionErrorReason)
}
