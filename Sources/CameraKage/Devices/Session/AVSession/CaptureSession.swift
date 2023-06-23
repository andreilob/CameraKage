//
//  CaptureSession.swift
//  
//
//  Created by Lobont Andrei on 05.06.2023.
//

import AVFoundation

class CaptureSession: AVCaptureMultiCamSession, Session {
    weak var delegate: SessionDelegate?
    
    func startSession() {
        startRunning()
    }
    
    func stopSession() {
        stopRunning()
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sessionRuntimeError),
                                               name: .AVCaptureSessionRuntimeError,
                                               object: self)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sessionWasInterrupted),
                                               name: .AVCaptureSessionWasInterrupted,
                                               object: self)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sessionInterruptionEnded),
                                               name: .AVCaptureSessionInterruptionEnded,
                                               object: self)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sessionDidStartRunning),
                                               name: .AVCaptureSessionDidStartRunning,
                                               object: self)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sessionDidStopRunning),
                                               name: .AVCaptureSessionDidStopRunning,
                                               object: self)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(deviceSubjectAreaDidChange),
                                               name: .AVCaptureDeviceSubjectAreaDidChange,
                                               object: self)
    }
    
    func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func sessionRuntimeError(notification: NSNotification) {
        guard let error = notification.userInfo?[AVCaptureSessionErrorKey] as? AVError else { return }
        let cameraError = CameraError.cameraSessionError(reason: .runtimeError(error))
        delegate?.session(self,
                          didReceiveRuntimeError: cameraError,
                          shouldRestartCamera: error.code == .mediaServicesWereReset)
    }
    
    @objc private func sessionDidStartRunning(notification: NSNotification) {
        delegate?.sessionDidStartCameraSession(self)
    }
    
    @objc private func sessionDidStopRunning(notification: NSNotification) {
        delegate?.sessionDidStopCameraSession(self)
    }
    
    /// This will be called anytime there is another app that tries to use the audio or video devices
    /// Removing that device will unfreeze the camera but video will be corrupted (couldn't find a reason yet)
    @objc private func sessionWasInterrupted(notification: NSNotification) {
        guard let userInfoValue = notification.userInfo?[AVCaptureSessionInterruptionReasonKey] as AnyObject?,
              let reasonIntegerValue = userInfoValue.integerValue,
              let reason = AVCaptureSession.InterruptionReason(rawValue: reasonIntegerValue) else { return }
        var interruptionReason: SessionInterruptionReason
        switch reason {
        case .videoDeviceNotAvailableInBackground:
            interruptionReason = .videoDeviceNotAvailableInBackground
        case .audioDeviceInUseByAnotherClient:
            interruptionReason = .audioDeviceInUseByAnotherClient
        case .videoDeviceInUseByAnotherClient:
            interruptionReason = .videoDeviceInUseByAnotherClient
        case .videoDeviceNotAvailableWithMultipleForegroundApps:
            interruptionReason = .videoDeviceNotAvailableWithMultipleForegroundApps
        case .videoDeviceNotAvailableDueToSystemPressure:
            interruptionReason = .videoDeviceNotAvailableDueToSystemPressure
        @unknown default:
            interruptionReason = .unknown
        }
        delegate?.session(self, didReceiveSessionInterruption: interruptionReason)
    }
    
    /// This will be called anytime the problem with the session was solved
    /// Entering in this method dosen't necessarly means that the call or the other application that invoked the problem was closed
    @objc private func sessionInterruptionEnded(notification: NSNotification) {
        delegate?.sessionDidFinishSessionInterruption(self)
    }
    
    @objc private func deviceSubjectAreaDidChange(notification: NSNotification) {
        delegate?.sessionDidChangeDeviceAreaOfInterest(self)
    }
}
