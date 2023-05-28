//
//  SessionComposable.swift
//  CameraKage
//
//  Created by Lobont Andrei on 26.05.2023.
//

import AVFoundation

protocol SessionComposable {
    var isSessionRunning: Bool { get }
    var outputs: [AVCaptureOutput] { get }
    var inputs: [AVCaptureInput] { get }
    var onSessionReceiveRuntimeError: ((Bool, AVError) -> Void)? { get set }
    var onSessionStart: (() -> Void)? { get set }
    var onSessionStop: (() -> Void)? { get set }
    var onSessionInterruption: ((SessionInterruptionReason) -> Void)? { get set }
    var onSessionInterruptionEnd: (() -> Void)? { get set }
    var onDeviceSubjectAreaChange: (() -> Void)? { get set }
    
    func beginConfiguration()
    func commitConfiguration()
    func canAddInput(_ input: AVCaptureInput) -> Bool
    func addInput(_ input: AVCaptureInput)
    func addInputWithNoConnections(_ input: AVCaptureInput)
    func canAddOutput(_ output: AVCaptureOutput) -> Bool
    func addOutput(_ output: AVCaptureOutput)
    func canAddConnection(_ connection: AVCaptureConnection) -> Bool
    func addConnection(_ connection: AVCaptureConnection)
    func connectPreviewLayer(_ previewLayer: AVCaptureVideoPreviewLayer)
    func cleanupSession()
    func startSession()
    func stopSession()
    func pauseSession()
    func resumeSession()
}
