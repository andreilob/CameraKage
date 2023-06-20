//
//  InteractableCamera.swift
//  
//
//  Created by Lobont Andrei on 30.05.2023.
//

import Foundation
import QuartzCore.CALayer

class InteractableCamera: SessionCamera, InteractableCameraInterface {
    var isZoomAllowed: Bool { options.pinchToZoomEnabled }
    var maxZoomScale: CGFloat { options.maximumZoomScale }
    
    func flipCamera() throws {
        do {
            try videoInput.flip()
        } catch let error {
            throw error
        }
    }
    
    func focus(with focusMode: FocusMode,
               exposureMode: ExposureMode,
               at devicePoint: CGPoint,
               monitorSubjectAreaChange: Bool) throws {
        do {
            let point = videoLayer.captureDevicePointConverted(fromLayerPoint: devicePoint)
            try videoInput.focus(focusMode: focusMode,
                                 exposureMode: exposureMode,
                                 point: point,
                                 monitorSubjectAreaChange: monitorSubjectAreaChange)
        } catch let error {
            throw error
        }
    }
    
    func zoom(atScale scale: CGFloat) throws {
        do {
            try videoInput.zoom(atScale: scale)
        } catch let error {
            throw error
        }
    }
    
    func minMaxZoom(_ factor: CGFloat) -> CGFloat {
        videoInput.minMaxZoom(factor, options: options)
    }
}
