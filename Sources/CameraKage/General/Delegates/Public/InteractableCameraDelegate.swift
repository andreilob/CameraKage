//
//  InteractableCameraDelegate.swift
//  
//
//  Created by Lobont Andrei on 05.06.2023.
//

import Foundation

public protocol InteractableCameraDelegate: SessionCameraDelegate {
    /**
     Called when a pinch to zoom action happened on the camera.
     
     - parameter scale: The current zoom scale reported by the pinch gesture.
     - parameter maxScale: The maximum zoom scale of the camera.
     */
    func cameraDidZoom(atScale scale: CGFloat, outOfMaximumScale maxScale: CGFloat)
}

public extension InteractableCameraDelegate {
    func cameraDidZoom(atScale scale: CGFloat, outOfMaximumScale maxScale: CGFloat) {}
}
