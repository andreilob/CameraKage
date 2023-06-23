//
//  ARCameraInterface.swift
//  
//
//  Created by Lobont Andrei on 21.06.2023.
//

import UIKit

protocol ARCameraInterface {
    var isSessionRunning: Bool { get }
    var isRecording: Bool { get }
    var delegateQueue: DispatchQueue { get }
    var delegate: ARCameraDelegate? { get set }
    
    func startCamera()
    func stopCamera()
    func resetCamera()
    func loadARMask(name: String, fileType: String)
    func capturePhoto()
    func startVideoRecording()
    func stopVideoRecording()
    func embedPreview(inView view: UIView)
}
