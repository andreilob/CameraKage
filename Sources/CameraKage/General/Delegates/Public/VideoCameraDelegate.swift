//
//  File.swift
//  
//
//  Created by Lobont Andrei on 13.06.2023.
//

import Foundation

public protocol VideoCameraDelegate: BaseCameraDelegate {
    /**
     Called when the camera has started a video recording.
     
     - parameter url: The URL file location where the video is being recorded.
     */
    func cameraDidStartVideoRecording(atFileURL url: URL)
    
    /**
     Called when the camera has outputted a video recording.
     
     - parameter url: The URL of the video file location.
     */
    func cameraDidFinishVideoRecording(atFileURL url: URL)
}

public extension VideoCameraDelegate {
    func cameraDidStartVideoRecording(atFileURL url: URL) {}
}
