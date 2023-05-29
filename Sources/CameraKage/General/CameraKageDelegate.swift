//
//  CameraKageDelegate.swift
//  CameraKage
//
//  Created by Lobont Andrei on 24.05.2023.
//

import Foundation

/// Delegate protocol used to notify events and pass information in regards to them.
public protocol CameraKageDelegate: AnyObject {
    /**
     Called when the camera has outputted a photo.
     
     - parameter camera: The camera composer which is sending the event.
     - parameter data: The data representation of the photo.
     */
    func camera(_ camera: CameraKage, didOutputPhotoWithData data: Data)
    
    /**
     Called when the camera has started a video recording.
     
     - parameter camera: The camera composer which is sending the event.
     - parameter url: The file location where the video will be stored when recording ends.
     */
    func camera(_ camera: CameraKage, didStartRecordingVideoAtFileURL url: URL)
    
    /**
     Called when the camera has outputted a video recording.
     
     - parameter camera: The camera composer which is sending the event.
     - parameter url: The file location where the video is stored.
     */
    func camera(_ camera: CameraKage, didOutputVideoAtFileURL url: URL)
    
    /**
     Called when a pinch to zoom action happened on the camera component.
     
     - parameter camera: The camera composer which is sending the event.
     - parameter scale: The current zoom scale reported by the pinch gesture.
     - parameter maxScale: The maximum zoom scale of the camera.
     */
    func camera(_ camera: CameraKage, didZoomAtScale scale: CGFloat, outOfMaximumScale maxScale: CGFloat)
    
    /**
     Called when the camera composer encountered an error. Could be an output, camera or a session related error.
     
     - parameter camera: The camera composer which is sending the event.
     - parameter error: The error that was encountered.
     */
    func camera(_ camera: CameraKage, didEncounterError error: CameraError)
    
    /**
     Called when the camera session was interrupted. This can happen from various reason but most common ones would be phone calls while using the camera, other apps taking control over the phone camera or app moving to background.
     
     - parameter camera: The camera composer which is sending the event.
     - parameter reason: The reason for the session interruption.
     
     - important: When this is called, the camera will freezee so some UI overlay might be necessary on the client side.
     */
    func camera(_ camera: CameraKage, sessionWasInterrupted reason: SessionInterruptionReason)
    
    /**
     Called when the camera session interruption has ended. When this is called the camera will resume working.
     
     - parameter camera: The camera composer which is sending the event.
     */
    func cameraSessionInterruptionEnded(_ camera: CameraKage)
    
    /**
     Called when the camera session was started and the actual camera will be visible on screen.
     
     - parameter camera: The camera composer which is sending the event.
     */
    func cameraSessionDidStart(_ camera: CameraKage)
    
    /**
     Called when the camera session has stopped.
     
     - parameter camera: The camera composer which is sending the event.
     */
    func cameraSessionDidStop(_ camera: CameraKage)
    
    /**
     Posted when the instance of AVCaptureDevice has detected a substantial change to the video subject area. This notification is only sent if you first set monitorSubjectAreaChange to `true` in the `focus()` camera method.
     
     - parameter camera: The camera composer which is sending the event.
     */
    func cameraDeviceDidChangeSubjectArea(_ camera: CameraKage)
}

public extension CameraKageDelegate {
    func camera(_ camera: CameraKage, didOutputPhotoWithData data: Data) {}
    func camera(_ camera: CameraKage, didStartRecordingVideoAtFileURL url: URL) {}
    func camera(_ camera: CameraKage, didOutputVideoAtFileURL url: URL) {}
    func camera(_ camera: CameraKage, didZoomAtScale scale: CGFloat, outOfMaximumScale maxScale: CGFloat) {}
    func camera(_ camera: CameraKage, didEncounterError error: CameraError) {}
    func camera(_ camera: CameraKage, sessionWasInterrupted reason: SessionInterruptionReason) {}
    func cameraSessionInterruptionEnded(_ camera: CameraKage) {}
    func cameraSessionDidStart(_ camera: CameraKage) {}
    func cameraSessionDidStop(_ camera: CameraKage) {}
    func cameraDeviceDidChangeSubjectArea(_ camera: CameraKage) {}
}
