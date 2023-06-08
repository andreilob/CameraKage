//
//  CameraComposerProtocol.swift
//  
//
//  Created by Lobont Andrei on 08.06.2023.
//

import UIKit

protocol CameraComposerProtocol: UIView {
    var isSessionRunning: Bool { get }
    var isRecording: Bool { get }
    var delegate: CameraComposerDelegate? { get set }
    
    func startCameraSession(with options: CameraComponentParsedOptions)
    func stopCameraSession()
    func capturePhoto(_ flashOption: FlashMode, redEyeCorrection: Bool)
    func startVideoRecording(_ flashOption: FlashMode)
    func stopVideoRecording()
    func flipCamera()
    func adjustFocusAndExposure(with focusMode: FocusMode,
                                exposureMode: ExposureMode,
                                at devicePoint: CGPoint,
                                monitorSubjectAreaChange: Bool)
}
