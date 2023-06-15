//
//  AudioCaptureDevice.swift
//  
//
//  Created by Lobont Andrei on 06.06.2023.
//

import AVFoundation

class AudioCaptureDevice: AudioInput {
    private let session: CaptureSession
    private let options: CameraComponentParsedOptions
    private(set) var audioDevice: AVCaptureDevice!
    private(set) var audioDeviceInput: AVCaptureDeviceInput!
    private(set) var audioDevicePort: AVCaptureDeviceInput.Port!
    
    init?(session: CaptureSession,
          options: CameraComponentParsedOptions) {
        self.session = session
        self.options = options
        guard configureAudioDevice() else { return nil }
    }
    
    private func configureAudioDevice() -> Bool {
        do {
            guard let audioDevice = AVCaptureDevice.default(for: .audio) else { return false }
            self.audioDevice = audioDevice
            
            let audioDeviceInput = try AVCaptureDeviceInput(device: audioDevice)
            guard session.canAddInput(audioDeviceInput) else { return false }
            session.addInputWithNoConnections(audioDeviceInput)
            self.audioDeviceInput = audioDeviceInput
            
            guard let audioPort = audioDeviceInput.ports(for: .audio,
                                                         sourceDeviceType: .builtInMicrophone,
                                                         sourceDevicePosition: .back).first else { return false }
            self.audioDevicePort = audioPort
            return true
        } catch {
            return false
        }
    }
}
