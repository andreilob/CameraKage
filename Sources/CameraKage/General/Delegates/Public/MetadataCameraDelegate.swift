//
//  MetadataCameraDelegate.swift
//  
//
//  Created by Lobont Andrei on 19.06.2023.
//

import Foundation

/// Delegate protocol used by the `MetadataCameraView`.
public protocol MetadataCameraDelegate: SessionCameraDelegate {
    /**
     Called when there was a successful metadata scan for the specified metadata types.
     
     - parameter metadata: An array representing all the metadata that was detected.
     */
    func cameraDidScanMetadataInfo(metadata: [MetadataScanOutput])
}
