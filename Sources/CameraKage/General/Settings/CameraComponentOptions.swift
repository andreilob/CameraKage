//
//  CameraComponentOptions.swift
//  CameraKage
//
//  Created by Lobont Andrei on 11.05.2023.
//

import Foundation

public typealias CameraComponentOptions = [CameraComponentOptionItem]

public enum CameraComponentOptionItem {
    /// Quality prioritization mode for the photo output.
    /// Constants indicating how photo quality should be prioritized against speed.
    /// Default is `.balanced`.
    case photoQualityPrioritizationMode(PhotoQualityPrioritizationMode)
    
    /// The mode of the video stabilization.
    /// Default is `.auto`.
    case videoStabilizationMode(VideoStabilizationMode)
    
    /// The orientation setting of the camera.
    /// Default is `.portrait`.
    case cameraOrientation(VideoOrientationMode)
    
    /// The type of camera to be used.
    /// Default is `.backWideCamera`.
    case cameraDevice(CameraDevice)
    
    /// The type of camera to be used when camera is being flipped.
    /// Default is `.frontCamera`.
    case flipCameraDevice(CameraDevice)
    
    /// Will define how the layer will display the player's visual content.
    /// Default is `.resizeAspectFill`.
    case videoGravity(LayerVideoGravity)
    
    /// Maximum duration allowed for video recordings represented in seconds.
    /// Default is `.infinity`.
    case maxVideoDuration(Double)
    
    /// Indicates if the camera has pinch to zoom.
    /// Default is `false`.
    case pinchToZoomEnabled(Bool)
    
    /// The minimum zoom scale of the camera.
    /// Default is `1.0`.
    case minimumZoomScale(CGFloat)
    
    /// The maximum zoom scale of the camera.
    /// Default is `5.0`.
    case maximumZoomScale(CGFloat)
    
    /// The queue that will be used to notify delegate events.
    /// Default is `.main`.
    case delegateQueue(DispatchQueue)
}

/// Options used to configure a camera view.
public class CameraComponentParsedOptions {
    public var photoQualityPrioritizationMode: PhotoQualityPrioritizationMode = .balanced
    public var videoStabilizationMode: VideoStabilizationMode = .auto
    public var cameraOrientation: VideoOrientationMode = .portrait
    public var cameraDevice: CameraDevice = .backWideCamera
    public var flipCameraDevice: CameraDevice = .frontCamera
    public var videoGravity: LayerVideoGravity = .resizeAspectFill
    public var maxVideoDuration: Double = .infinity
    public var pinchToZoomEnabled: Bool = false
    public var minimumZoomScale: CGFloat = 1.0
    public var maximumZoomScale: CGFloat = 5.0
    public var delegateQeueue: DispatchQueue = .main
    
    public init(_ options: CameraComponentOptions?) {
        guard let options else { return }
        options.forEach {
            switch $0 {
            case .photoQualityPrioritizationMode(let photoQualityPrioritizationMode):
                self.photoQualityPrioritizationMode = photoQualityPrioritizationMode
            case .videoStabilizationMode(let videoStabilizationMode):
                self.videoStabilizationMode = videoStabilizationMode
            case .cameraOrientation(let cameraOrientation):
                self.cameraOrientation = cameraOrientation
            case .cameraDevice(let cameraDevice):
                self.cameraDevice = cameraDevice
            case .flipCameraDevice(let flipCameraDevice):
                self.flipCameraDevice = flipCameraDevice
            case .videoGravity(let videoGravity):
                self.videoGravity = videoGravity
            case .maxVideoDuration(let maxVideoDuration):
                self.maxVideoDuration = maxVideoDuration
            case .pinchToZoomEnabled(let pinchToZoomEnabled):
                self.pinchToZoomEnabled = pinchToZoomEnabled
            case .minimumZoomScale(let minimumZoomScale):
                self.minimumZoomScale = minimumZoomScale
            case .maximumZoomScale(let maximumZoomScale):
                self.maximumZoomScale = maximumZoomScale
            case .delegateQueue(let delegateQueue):
                self.delegateQeueue = delegateQueue
            }
        }
    }
}
