//
//  VideoLayer.swift
//  
//
//  Created by Lobont Andrei on 09.06.2023.
//

import UIKit

protocol VideoLayer {
    func embedPreviewLayer(in layer: CALayer)
    func setPreviewLayerFrame(_ frame: CGRect)
    func removeFromSuperlayer()
    func reloadPreviewLayer() throws
    func captureDevicePointConverted(fromLayerPoint: CGPoint) -> CGPoint
}
