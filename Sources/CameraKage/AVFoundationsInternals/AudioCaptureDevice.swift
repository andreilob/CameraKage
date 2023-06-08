//
//  AudioCaptureDevice.swift
//  
//
//  Created by Lobont Andrei on 06.06.2023.
//

import AVFoundation

class AudioCaptureDevice {
    private(set) var audioDevice: AVCaptureDevice!
    private(set) var audioDeviceInput: AVCaptureDeviceInput!
    private(set) var audioDevicePort: AVCaptureDeviceInput.Port!
    
    func configureAudioDevice(forSession session: CaptureSession,
                              andOptions options: CameraComponentParsedOptions,
                              isFlipped: Bool) -> Bool {
        do {
            let camera = isFlipped ? options.flipCameraDevice : options.cameraDevice
            guard let audioDevice = AVCaptureDevice.default(for: .audio) else { return false }
            self.audioDevice = audioDevice
            
            let audioDeviceInput = try AVCaptureDeviceInput(device: audioDevice)
            guard session.canAddInput(audioDeviceInput) else { return false }
            session.addInputWithNoConnections(audioDeviceInput)
            self.audioDeviceInput = audioDeviceInput
            
            guard let audioPort = audioDeviceInput.ports(for: .audio,
                                                         sourceDeviceType: .builtInMicrophone,
                                                         sourceDevicePosition: camera.avDevicePosition).first else { return false }
            self.audioDevicePort = audioPort
            return true
        } catch {
            return false
        }
    }
}
