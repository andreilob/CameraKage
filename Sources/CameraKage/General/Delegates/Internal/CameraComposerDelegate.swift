//
//  CameraComposerDelegate.swift
//  
//
//  Created by Lobont Andrei on 05.06.2023.
//

import Foundation

protocol CameraComposerDelegate: AnyObject {
    func cameraComposer(_ cameraComposer: CameraComposer,
                         didCapturePhoto photo: Data)
    func cameraComposer(_ cameraComposer: CameraComposer,
                         didStartRecordingVideo atFileURL: URL)
    func cameraComposer(_ cameraComposer: CameraComposer,
                         didRecordVideo videoURL: URL)
    func cameraComposer(_ cameraComposer: CameraComposer,
                         didZoomAtScale scale: CGFloat,
                         outOfMaximumScale maxScale: CGFloat)
    func cameraComposer(_ cameraComposer: CameraComposer,
                        didReceiveError error: CameraError)
    func cameraComposer(_ cameraComposer: CameraComposer,
                        didReceiveSessionInterruption reason: SessionInterruptionReason)
    func cameraComposerDidFinishSessionInterruption(_ cameraComposer: CameraComposer)
    func cameraComposerDidStartCameraSession(_ cameraComposer: CameraComposer)
    func cameraComposerDidStopCameraSession(_ cameraComposer: CameraComposer)
    func cameraComposerDidChangeDeviceAreaOfInterest(_ cameraComposer: CameraComposer)
}
