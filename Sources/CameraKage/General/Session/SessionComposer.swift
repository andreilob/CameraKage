//
//  SessionComposer.swift
//  CameraKage
//
//  Created by Lobont Andrei on 26.05.2023.
//

import AVFoundation

final class SessionComposer: SessionComposable {
    private let session: AVCaptureMultiCamSession
    private let sessionDelegate: SessionDelegate
    
    var isSessionRunning: Bool { session.isRunning }
    var outputs: [AVCaptureOutput] { session.outputs }
    var inputs: [AVCaptureInput] { session.inputs }
    var connections: [AVCaptureConnection] { session.connections }
    var onSessionReceiveRuntimeError: ((Bool, AVError) -> Void)?
    var onSessionStart: (() -> Void)?
    var onSessionStop: (() -> Void)?
    var onSessionInterruption: ((SessionInterruptionReason) -> Void)?
    var onSessionInterruptionEnd: (() -> Void)?
    var onDeviceSubjectAreaChange: (() -> Void)?
    
    init() {
        self.session = AVCaptureMultiCamSession()
        self.sessionDelegate = SessionDelegate(session: session)
    }
    
    func beginConfiguration() {
        session.beginConfiguration()
    }
    
    func commitConfiguration() {
        session.commitConfiguration()
    }
    
    func canAddInput(_ input: AVCaptureInput) -> Bool {
        session.canAddInput(input)
    }
    
    func addInput(_ input: AVCaptureInput) {
        session.addInput(input)
    }
    
    func addInputWithNoConnections(_ input: AVCaptureInput) {
        session.addInputWithNoConnections(input)
    }
    
    func canAddOutput(_ output: AVCaptureOutput) -> Bool {
        session.canAddOutput(output)
    }
    
    func addOutput(_ output: AVCaptureOutput) {
        session.addOutputWithNoConnections(output)
    }
    
    func canAddConnection(_ connection: AVCaptureConnection) -> Bool {
        session.canAddConnection(connection)
    }
    
    func addConnection(_ connection: AVCaptureConnection) {
        session.addConnection(connection)
    }
    
    func connectPreviewLayer(_ previewLayer: AVCaptureVideoPreviewLayer) {
        previewLayer.setSessionWithNoConnection(session)
    }
    
    func cleanupSession() {
        session.outputs.forEach { session.removeOutput($0) }
        session.inputs.forEach { session.removeInput($0) }
        session.connections.forEach { session.removeConnection($0) }
    }
    
    func startSession() {
        setupDelegate()
        sessionDelegate.addObservers()
        session.startRunning()
    }
    
    func stopSession() {
        session.stopRunning()
        sessionDelegate.removeObservers()
    }
    
    func pauseSession() {
        session.stopRunning()
    }
    
    func resumeSession() {
        session.startRunning()
    }
    
    private func setupDelegate() {
        sessionDelegate.onSessionStart = onSessionStart
        sessionDelegate.onSessionStop = onSessionStop
        sessionDelegate.onSessionInterruption = onSessionInterruption
        sessionDelegate.onSessionInterruptionEnd = onSessionInterruptionEnd
        sessionDelegate.onReceiveRuntimeError = onSessionReceiveRuntimeError
        sessionDelegate.onDeviceSubjectAreaChange = onDeviceSubjectAreaChange
    }
}
