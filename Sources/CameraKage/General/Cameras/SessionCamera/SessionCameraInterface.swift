//
//  SessionCameraInterface.swift
//  
//
//  Created by Lobont Andrei on 16.06.2023.
//

import Foundation
import QuartzCore.CALayer

protocol SessionCameraInterface {
    var delegateQueue: DispatchQueue { get }
    var isSessionRunning: Bool { get }
    
    func startCameraSession()
    func stopCameraSession()
    func resumeCameraSession()
    func setSessionDelegate(_ delegate: SessionDelegate)
    func configureFlash(_ flashMode: FlashMode) throws
    func embedPreviewLayer(in layer: CALayer)
    func setPreviewLayerFrame(_ frame: CGRect)
    func removePreviewLayer()
}
