//
//  SessionDelegate.swift
//  CameraKage
//
//  Created by Lobont Andrei on 23.05.2023.
//

import AVFoundation

final class SessionDelegate {
    private let session: AVCaptureMultiCamSession
    
    var onReceiveRuntimeError: ((Bool, AVError) -> Void)?
    var onSessionStart: (() -> Void)?
    var onSessionStop: (() -> Void)?
    var onSessionInterruption: ((SessionInterruptionReason) -> Void)?
    var onSessionInterruptionEnd: (() -> Void)?
    var onDeviceSubjectAreaChange: (() -> Void)?
    
    init(session: AVCaptureMultiCamSession) {
        self.session = session
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sessionRuntimeError),
                                               name: .AVCaptureSessionRuntimeError,
                                               object: session)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sessionWasInterrupted),
                                               name: .AVCaptureSessionWasInterrupted,
                                               object: session)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sessionInterruptionEnded),
                                               name: .AVCaptureSessionInterruptionEnded,
                                               object: session)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sessionDidStartRunning),
                                               name: .AVCaptureSessionDidStartRunning,
                                               object: session)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sessionDidStopRunning),
                                               name: .AVCaptureSessionDidStopRunning,
                                               object: session)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(deviceSubjectAreaDidChange),
                                               name: .AVCaptureDeviceSubjectAreaDidChange,
                                               object: session)
    }
    
    func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func sessionRuntimeError(notification: NSNotification) {
        guard let error = notification.userInfo?[AVCaptureSessionErrorKey] as? AVError else { return }
        onReceiveRuntimeError?(error.code == .mediaServicesWereReset, error)
    }
    
    @objc private func sessionDidStartRunning(notification: NSNotification) {
        onSessionStart?()
    }
    
    @objc private func sessionDidStopRunning(notification: NSNotification) {
        onSessionStop?()
    }
    
    /// This will be called anytime there is another app that tries to use the audio or video devices
    /// Removing that device will unfreeze the camera but video will be corrupted (couldn't find a reason yet)
    @objc private func sessionWasInterrupted(notification: NSNotification) {
        guard let userInfoValue = notification.userInfo?[AVCaptureSessionInterruptionReasonKey] as AnyObject?,
              let reasonIntegerValue = userInfoValue.integerValue,
              let reason = AVCaptureSession.InterruptionReason(rawValue: reasonIntegerValue) else { return }
        switch reason {
        case .videoDeviceNotAvailableInBackground:
            onSessionInterruption?(.videoDeviceNotAvailableInBackground)
        case .audioDeviceInUseByAnotherClient:
            onSessionInterruption?(.audioDeviceInUseByAnotherClient)
        case .videoDeviceInUseByAnotherClient:
            onSessionInterruption?(.videoDeviceInUseByAnotherClient)
        case .videoDeviceNotAvailableWithMultipleForegroundApps:
            onSessionInterruption?(.videoDeviceNotAvailableWithMultipleForegroundApps)
        case .videoDeviceNotAvailableDueToSystemPressure:
            onSessionInterruption?(.videoDeviceNotAvailableDueToSystemPressure)
        @unknown default:
            onSessionInterruption?(.unknown)
        }
    }
    
    /// This will be called anytime the problem with the session was solved
    /// Entering in this method dosen't necessarly means that the call or the other application that invoked the problem was closed
    @objc private func sessionInterruptionEnded(notification: NSNotification) {
        onSessionInterruptionEnd?()
    }
    
    @objc private func deviceSubjectAreaDidChange(notification: NSNotification) {
        onDeviceSubjectAreaChange?()
    }
}
