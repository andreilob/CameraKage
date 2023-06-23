//
//  ARPreviewViewMock.swift
//  
//
//  Created by Lobont Andrei on 22.06.2023.
//

import UIKit
@testable import CameraKage

class ARPreviewViewMock: ARPreviewer {
    var isSessionRunning: Bool = false
    var currentMaskNameAndFileType: String?
    
    weak var embedingView: UIView?
    weak var sessionDelegate: ARSessionDelegate?
    
    func startCameraSession() {
        isSessionRunning = true
    }
    
    func stopCameraSession() {
        isSessionRunning = false
    }
    
    func embedPreview(inView view: UIView) {
        embedingView = view
    }
    
    func loadARMask(name: String, fileType: String) {
        currentMaskNameAndFileType = "\(name).\(fileType)"
    }
    
    func resetCamera() {
        currentMaskNameAndFileType = nil
    }
}
