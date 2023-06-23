//
//  ARCameraViewDelegate.swift
//  
//
//  Created by Lobont Andrei on 22.06.2023.
//

import Foundation

/// Delegate protocol used by the `ARCameraView`.
public protocol ARCameraViewDelegate: AnyObject {
    /**
     Called when the AR camera has outputted a photo.
     
     - parameter data: The data representation of the photo.
     */
    func arCamera(didCapturePhotoWithData data: Data)
    
    /**
     Called when the AR camera has started a video recording.
     
     - parameter url: The URL file location where the video is being recorded.
     */
    func arCamera(didBeginRecordingVideoAtURL url: URL)
    
    /**
     Called when the camera has outputted a video recording.
     
     - parameter url: The URL of the video file location.
     */
    func arCamera(didRecordVideoAtURL url: URL)
    
    /**
     Called when the AR camera encountered an error.
     
     - parameter error: The error that was encountered.
     */
    func arCamera(didFailWithError error: ARCameraError)
    
    /**
     Called when the camera session was interrupted. This can happen from various reason but most common ones would be phone calls while using the camera, other apps taking control over the phone camera or app moving to background.
     
     - important: When this is called, the camera will freezee so some UI overlay might be necessary on the client side.
     */
    func arCameraWasInterrupted()
    
    /**
     Called when the camera session interruption has ended. When this is called the camera will resume working.
     */
    func arCameraInterruptionEnded()
}
