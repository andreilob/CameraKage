//
//  CameraComponentOptions.swift
//  CameraKage
//
//  Created by Lobont Andrei on 11.05.2023.
//

import AVFoundation

public typealias CameraComponentOptions = [CameraComponentOptionItem]

public enum CameraComponentOptionItem {
    /// Quality prioritization mode for the photo output.
    /// Constants indicating how photo quality should be prioritized against speed.
    /// Default is `.balanced`.
    case photoQualityPrioritizationMode(AVCapturePhotoOutput.QualityPrioritization)
    
    /// The mode of the video stabilization.
    /// Default is `.auto`.
    case videoStabilizationMode(AVCaptureVideoStabilizationMode)
    
    /// The orientation setting of the camera.
    /// Default is `.portrait`.
    case cameraOrientation(AVCaptureVideoOrientation)
    
    /// The type of camera to be used.
    /// Default is `.backWideCamera`.
    case cameraDevice(CameraDevice)
    
    /// The type of camera to be used when camera is being flipped.
    /// Default is `.frontCamera`.
    case flipCameraDevice(CameraDevice)
    
    /// Will define how the layer will display the player's visual content.
    /// Default is `.resizeAspectFill`.
    case videoGravity(AVLayerVideoGravity)
    
    /// Maximum duration allowed for video recordings.
    /// Default is `.positiveInfinity`.
    case maxVideoDuration(CMTime)
    
    /// Indicates if the `CameraComponent` has pinch to zoom.
    /// Each `CameraComponent` can have its own zoom setting.
    /// Default is `false`.
    case pinchToZoomEnabled(Bool)
    
    /// The minimum zoom scale of the `CameraComponent`.
    /// Each `CameraComponent` can have its own minimum scale.
    /// Default is `1.0`.
    case minimumZoomScale(CGFloat)
    
    /// The maximum zoom scale of the `CameraComponent`.
    /// Each `CameraComponent` can have its own maximum scale.
    /// Default is `5.0`.
    case maximumZoomScale(CGFloat)
}

/// Options used for the output settings of the camera component.
/// These should be set before the `startCameraSession()` is called.
public class CameraComponentParsedOptions {
    public var photoQualityPrioritizationMode: AVCapturePhotoOutput.QualityPrioritization = .balanced
    public var videoStabilizationMode: AVCaptureVideoStabilizationMode = .auto
    public var cameraOrientation: AVCaptureVideoOrientation = .portrait
    public var cameraDevice: CameraDevice = .backWideCamera
    public var flipCameraDevice: CameraDevice = .frontCamera
    public var videoGravity: AVLayerVideoGravity = .resizeAspectFill
    public var maxVideoDuration: CMTime = .positiveInfinity
    public var pinchToZoomEnabled: Bool = false
    public var minimumZoomScale: CGFloat = 1.0
    public var maximumZoomScale: CGFloat = 5.0
    
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
            }
        }
    }
}
