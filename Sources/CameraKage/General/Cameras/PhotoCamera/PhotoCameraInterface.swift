//
//  PhotoCameraInterface.swift
//  
//
//  Created by Lobont Andrei on 11.06.2023.
//

import Foundation

protocol PhotoCameraInterface: InteractableCameraInterface {
    var onPhotoCaptureSuccess: ((Data) -> Void)? { get set }
    var onPhotoCaptureError: ((CameraError) -> Void)? { get set }
    
    func capturePhoto(_ flashOption: FlashMode, redEyeCorrection: Bool)
}
