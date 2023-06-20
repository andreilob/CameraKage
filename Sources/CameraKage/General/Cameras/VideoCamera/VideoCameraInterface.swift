//
//  VideoCameraInterface.swift
//  
//
//  Created by Lobont Andrei on 11.06.2023.
//

import Foundation

protocol VideoCameraInterface: InteractableCameraInterface {
    var isRecording: Bool { get }
    var onMovieCaptureSuccess: ((URL) -> Void)? { get set }
    var onMovieCaptureStart: ((URL) -> Void)? { get set }
    var onMovieCaptureError: ((CameraError) -> Void)? { get set }
    
    func startVideoRecording()
    func stopVideoRecording()
}
