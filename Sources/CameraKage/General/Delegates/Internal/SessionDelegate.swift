//
//  SessionDelegate.swift
//  
//
//  Created by Lobont Andrei on 30.05.2023.
//

import AVFoundation

protocol SessionDelegate: AnyObject {
    func session(_ sessionComposer: Session,
                         didReceiveRuntimeError error: CameraError,
                         shouldRestartCamera restart: Bool)
    func session(_ sessionComposer: Session,
                         didReceiveSessionInterruption reason: SessionInterruptionReason)
    func sessionDidFinishSessionInterruption(_ sessionComposer: Session)
    func sessionDidStartCameraSession(_ sessionComposer: Session)
    func sessionDidStopCameraSession(_ sessionComposer: Session)
    func sessionDidChangeDeviceAreaOfInterest(_ sessionComposer: Session)
}
