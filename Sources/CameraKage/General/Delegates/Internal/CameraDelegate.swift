//
//  CameraDelegate.swift
//  
//
//  Created by Lobont Andrei on 05.06.2023.
//

import Foundation

protocol CameraDelegate: AnyObject {
    func camera(_ camera: Camera, didCapturePhoto photo: Data)
    func camera(_ camera: Camera, didStartRecordingVideo atFileURL: URL)
    func camera(_ camera: Camera, didRecordVideo videoURL: URL)
    func camera(_ camera: Camera, didZoomAtScale scale: CGFloat, outOfMaximumScale maxScale: CGFloat)
    func camera(_ camera: Camera, didFail withError: CameraError)
}
