//
//  BaseCameraInterface.swift
//  
//
//  Created by Lobont Andrei on 11.06.2023.
//

import Foundation
import QuartzCore.CALayer

protocol BaseCameraInterface {
    var isZoomAllowed: Bool { get }
    var delegateQueue: DispatchQueue { get }
    var isSessionRunning: Bool { get }
    var maxZoomScale: CGFloat { get }
    
    func startCameraSession()
    func stopCameraSession()
    func resumeCameraSession()
    func setSessionDelegate(_ delegate: SessionDelegate)
    func flipCamera() throws
    func focus(with focusMode: FocusMode,
               exposureMode: ExposureMode,
               at devicePoint: CGPoint,
               monitorSubjectAreaChange: Bool) throws
    func zoom(atScale scale: CGFloat) throws
    func minMaxZoom(_ factor: CGFloat) -> CGFloat
    func configureFlash(_ flashMode: FlashMode) throws
    func embedPreviewLayer(in layer: CALayer)
    func setPreviewLayerFrame(_ frame: CGRect)
    func removePreviewLayer()
}
