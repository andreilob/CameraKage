//
//  PhotoCameraDelegate.swift
//  
//
//  Created by Lobont Andrei on 12.06.2023.
//

import Foundation

/// Delegate protocol used by the `PhotoCameraView`.
public protocol PhotoCameraDelegate: BaseCameraDelegate {
    /**
     Called when the camera has outputted a photo.
     
     - parameter data: The data representation of the photo.
     */
    func cameraDidCapturePhoto(withData data: Data)
}
