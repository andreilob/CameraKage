//
//  SessionComposerProtocol.swift
//  CameraKage
//
//  Created by Lobont Andrei on 26.05.2023.
//

import AVFoundation

protocol SessionComposerProtocol {
    var delegate: SessionComposerDelegate? { get set }
    var isSessionRunning: Bool { get }
    
    func startSession()
    func stopSession()
    func pauseSession()
    func resumeSession()
    func createCamera(_ options: CameraComponentParsedOptions) -> Result<Camera, CameraError>
}
