//
//  BaseCameraDelegate.swift
//  
//
//  Created by Lobont Andrei on 05.06.2023.
//

import Foundation

public protocol BaseCameraDelegate: AnyObject {
    /**
     Called when a pinch to zoom action happened on the camera.
     
     - parameter scale: The current zoom scale reported by the pinch gesture.
     - parameter maxScale: The maximum zoom scale of the camera.
     */
    func cameraDidZoom(atScale scale: CGFloat, outOfMaximumScale maxScale: CGFloat)
    
    /**
     Called when the camera encountered an error.
     
     - parameter error: The error that was encountered.
     */
    func cameraDidEncounterError(error: CameraError)
    
    /**
     Called when the camera session was interrupted. This can happen from various reason but most common ones would be phone calls while using the camera, other apps taking control over the phone camera or app moving to background.
     
     - parameter reason: The reason for the session interruption.
     
     - important: When this is called, the camera will freezee so some UI overlay might be necessary on the client side.
     */
    func cameraDidReceiveSessionInterruption(withReason reason: SessionInterruptionReason)
    
    /**
     Called when the camera session interruption has ended. When this is called the camera will resume working.
     */
    func cameraDidFinishSessionInterruption()
    
    /**
     Called when the camera session was started and the actual camera will be visible on screen.
     */
    func cameraDidStartCameraSession()
    
    /**
     Called when the camera session has stopped.
     */
    func cameraDidStopCameraSession()
    
    /**
     Called when the instance of AVCaptureDevice has detected a substantial change to the video subject area. This notification is only sent if you first set monitorSubjectAreaChange to `true` in the `focus()` camera method.
     */
    func cameraDidChangeDeviceAreaOfInterest()
}

public extension BaseCameraDelegate {
    func cameraDidZoom(atScale scale: CGFloat, outOfMaximumScale maxScale: CGFloat) {}
    func cameraDidEncounterError(error: CameraError) {}
    func cameraDidReceiveSessionInterruption(withReason reason: SessionInterruptionReason) {}
    func cameraDidFinishSessionInterruption() {}
    func cameraDidStartCameraSession() {}
    func cameraDidStopCameraSession() {}
    func cameraDidChangeDeviceAreaOfInterest() {}
}
