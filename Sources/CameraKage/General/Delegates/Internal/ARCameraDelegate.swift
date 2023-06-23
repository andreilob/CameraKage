//
//  ARCameraDelegate.swift
//  
//
//  Created by Lobont Andrei on 21.06.2023.
//

import Foundation

protocol ARCameraDelegate: AnyObject {
    func arCamera(didCapturePhotoWithData data: Data)
    func arCamera(didBeginRecordingVideoAtURL url: URL)
    func arCamera(didRecordVideoAtURL url: URL)
    func arCamera(didFailWithError error: ARCameraError)
    func arCameraWasInterrupted()
    func arCameraInterruptionEnded()
}
