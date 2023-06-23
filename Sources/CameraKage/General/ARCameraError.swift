//
//  ARCameraError.swift
//  
//
//  Created by Lobont Andrei on 22.06.2023.
//

import Foundation

public enum ARCameraError {
    /// Current device dosen't support AR.
    case arNotSupported
    
    /// Starting the AR session failed. Contains original error message.
    case arSessionFailed(message: String?)
    
    /// The camera couldn't find a scene with the specified name and file type.
    case failedToLoadARMask(name: String, fileType: String)
    
    /// The AssetWriter failed to record the video.
    case failedToRecordARVideo
    
    /// The AssetWriter failed to capture the photo.
    case failedToCaptureARPhoto
    
    /// The audio buffer of the AR video recording failed to be written.
    case failedToRecordAudioBuffer
}
