//
//  CameraComponentDelegate.swift
//  
//
//  Created by Lobont Andrei on 05.06.2023.
//

import Foundation

protocol CameraComponentDelegate: AnyObject {
    func cameraComponent(_ cameraComponent: CameraComponent,
                         didCapturePhoto photo: Data)
    func cameraComponent(_ cameraComponent: CameraComponent,
                         didStartRecordingVideo atFileURL: URL)
    func cameraComponent(_ cameraComponent: CameraComponent,
                         didRecordVideo videoURL: URL)
    func cameraComponent(_ cameraComponent: CameraComponent,
                         didZoomAtScale scale: CGFloat,
                         outOfMaximumScale maxScale: CGFloat)
    func cameraComponent(_ cameraComponent: CameraComponent,
                         didFail withError: CameraError)
}
