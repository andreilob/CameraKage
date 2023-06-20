//
//  VideoInputMock.swift
//  
//
//  Created by Lobont Andrei on 14.06.2023.
//

import Foundation
@testable import CameraKage

class VideoInputMock: VideoInput {
    private let options: CameraComponentParsedOptions
    var onVideoDeviceError: ((CameraError) -> Void)?
    var zoomLevel = 1.0
    var flashMode: FlashMode?
    var focusMode: FocusMode?
    var exposureMode: ExposureMode?
    var focusPoint: CGPoint = .zero
    var isFlipped = false
    var currentCamera: CameraDevice {
        isFlipped ? options.flipCameraDevice : options.cameraDevice
    }
    
    init(options: CameraComponentParsedOptions) {
        self.options = options
    }
    
    func flip() throws {
        isFlipped.toggle()
    }
    
    func focus(focusMode: FocusMode,
               exposureMode: ExposureMode,
               point: CGPoint,
               monitorSubjectAreaChange: Bool) throws {
        self.focusMode = focusMode
        self.exposureMode = exposureMode
        self.focusPoint = point
    }
    
    func zoom(atScale: CGFloat) throws {
        guard atScale <= options.maximumZoomScale else { return }
        zoomLevel = atScale
    }
    
    func minMaxZoom(_ factor: CGFloat, options: CameraComponentParsedOptions) -> CGFloat {
        min(max(factor, options.minimumZoomScale), options.maximumZoomScale)
    }
    
    func configureFlash(_ flashMode: FlashMode) throws {
        guard currentCamera != .frontCamera else {
            throw CameraError.cameraComponentError(reason: .torchModeNotSupported)
        }
        self.flashMode = flashMode
    }
    
    func addObservers() {}
    func removeObservers() {}
}
