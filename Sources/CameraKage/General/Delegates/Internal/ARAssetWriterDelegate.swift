//
//  ARAssetWriterDelegate.swift
//  
//
//  Created by Lobont Andrei on 21.06.2023.
//

import Foundation

protocol ARAssetWriterDelegate: AnyObject {
    func assetWriter(didCapturePhotoWithData data: Data)
    func assetWriter(didBeginRecordingVideoAtURL url: URL)
    func assetWriter(didRecordVideoAtURL url: URL)
    func assetWriter(didEncounterError error: ARCameraError)
}
