//
//  ARPreviewer.swift
//  
//
//  Created by Lobont Andrei on 20.06.2023.
//

import UIKit

protocol ARPreviewer {
    var isSessionRunning: Bool { get }
    var sessionDelegate: ARSessionDelegate? { get set }
    
    func startCameraSession()
    func stopCameraSession()
    func embedPreview(inView view: UIView)
    func loadARMask(name: String, fileType: String)
    func resetCamera()
}
