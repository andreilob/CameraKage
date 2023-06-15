//
//  VideoLayerMock.swift
//  
//
//  Created by Lobont Andrei on 14.06.2023.
//

import Foundation
import QuartzCore.CALayer
@testable import CameraKage

class VideoLayerMock: VideoLayer {
    var parentLayer: CALayer?
    var layerFrame: CGRect = .zero
    
    func embedPreviewLayer(in layer: CALayer) {
        parentLayer = layer
    }
    
    func setPreviewLayerFrame(_ frame: CGRect) {
        layerFrame = frame
    }
    
    func removeFromSuperlayer() {
        parentLayer = nil
    }
    
    func reloadPreviewLayer() throws {}
    
    func captureDevicePointConverted(fromLayerPoint: CGPoint) -> CGPoint {
        .zero
    }
}
