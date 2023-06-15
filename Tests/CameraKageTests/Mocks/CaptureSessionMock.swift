//
//  CaptureSessionMock.swift
//  
//
//  Created by Lobont Andrei on 14.06.2023.
//

import Foundation
@testable import CameraKage

class CaptureSessionMock: Session {
    var isRunning = false
    var isSessionConfigurating = false
    var isObservingSession = false
    
    weak var delegate: SessionDelegate?
    
    func startSession() {
        isRunning = true
    }
    
    func stopSession() {
        isRunning = false
    }
    
    func beginConfiguration() {
        isSessionConfigurating = true
    }
    
    func commitConfiguration() {
        isSessionConfigurating = false
    }
    
    func addObservers() {
        isObservingSession = true
    }
    
    func removeObservers() {
        isObservingSession = false
    }
}
