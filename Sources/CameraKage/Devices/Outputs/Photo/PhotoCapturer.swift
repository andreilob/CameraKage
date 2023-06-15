//
//  PhotoCapturer.swift
//  
//
//  Created by Lobont Andrei on 09.06.2023.
//

import Foundation

protocol PhotoCapturer {
    var onPhotoCaptureSuccess: ((Data) -> Void)? { get set }
    var onPhotoCaptureError: ((CameraError) -> Void)? { get set }
    
    func capturePhoto(_ flashMode: FlashMode, redEyeCorrection: Bool)
    func handleFlip() throws
}
