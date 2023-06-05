//
//  SessionComposerDelegate.swift
//  
//
//  Created by Lobont Andrei on 30.05.2023.
//

import AVFoundation

protocol SessionComposerDelegate: AnyObject {
    func sessionComposer(_ sessionComposer: SessionComposerProtocol,
                         didReceiveRuntimeError error: CameraError,
                         shouldRestartCamera restart: Bool)
    func sessionComposer(_ sessionComposer: SessionComposerProtocol,
                         didReceiveSessionInterruption reason: SessionInterruptionReason)
    func sessionComposerDidFinishSessionInterruption(_ sessionComposer: SessionComposerProtocol)
    func sessionComposerDidStartCameraSession(_ sessionComposer: SessionComposerProtocol)
    func sessionComposerDidStopCameraSession(_ sessionComposer: SessionComposerProtocol)
    func sessionComposerDidChangeDeviceAreaOfInterest(_ sessionComposer: SessionComposerProtocol)
}
