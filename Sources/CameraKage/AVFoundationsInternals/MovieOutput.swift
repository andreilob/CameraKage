//
//  MovieOutput.swift
//  
//
//  Created by Lobont Andrei on 05.06.2023.
//

import AVFoundation

class MovieOutput: AVCaptureMovieFileOutput {
    private(set) var videoPortConnection: AVCaptureConnection?
    private(set) var audioPortConnection: AVCaptureConnection?
    
    var onMovieCaptureSuccess: ((URL) -> Void)?
    var onMovieCaptureStart: ((URL) -> Void)?
    var onMovieCaptureError: ((CameraError) -> Void)?
    
    func startMovieRecording() {
        guard !isRecording else { return }
        startRecording(to: .makeTempUrl(for: .video), recordingDelegate: self)
    }
    
    func stopMovieRecording() {
        stopRecording()
    }
    
    func configureMovieFileOutput(forSession session: CaptureSession,
                                  andOptions options: CameraComponentParsedOptions,
                                  videoDevice: VideoCaptureDevice,
                                  audioDevice: AudioCaptureDevice,
                                  isFlipped: Bool) -> Bool {
        let camera = isFlipped ? options.flipCameraDevice : options.cameraDevice
        guard session.canAddOutput(self) else { return false }
        session.addOutputWithNoConnections(self)
        maxRecordedDuration = options.maxVideoDuration
        
        let videoConnection = AVCaptureConnection(inputPorts: [videoDevice.videoDevicePort], output: self)
        guard session.canAddConnection(videoConnection) else { return false }
        session.addConnection(videoConnection)
        videoConnection.isVideoMirrored = camera.avDevicePosition == .front
        videoConnection.videoOrientation = options.cameraOrientation
        if videoConnection.isVideoStabilizationSupported {
            videoConnection.preferredVideoStabilizationMode = options.videoStabilizationMode
        }
        self.videoPortConnection = videoConnection
        
        let audioConnection = AVCaptureConnection(inputPorts: [audioDevice.audioDevicePort], output: self)
        guard session.canAddConnection(audioConnection) else { return false }
        session.addConnection(audioConnection)
        if availableVideoCodecTypes.contains(.hevc) {
            setOutputSettings([AVVideoCodecKey: AVVideoCodecType.hevc],
                                              for: videoConnection)
        }
        self.audioPortConnection = audioConnection
        
        return true
    }
}

// MARK: - AVCaptureFileOutputRecordingDelegate
extension MovieOutput: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput,
                    didStartRecordingTo fileURL: URL,
                    from connections: [AVCaptureConnection]) {
        onMovieCaptureStart?(fileURL)
    }
    
    func fileOutput(_ output: AVCaptureFileOutput,
                    didFinishRecordingTo outputFileURL: URL,
                    from connections: [AVCaptureConnection],
                    error: Error?) {
        guard error == nil else {
            cleanup(outputFileURL)
            onMovieCaptureError?(.cameraComponentError(reason: .failedToOutputMovie(message: error?.localizedDescription)))
            return
        }
        onMovieCaptureSuccess?(outputFileURL)
    }
    
    private func cleanup(_ url: URL) {
        let path = url.path
        if FileManager.default.fileExists(atPath: path) {
            do {
                try FileManager.default.removeItem(atPath: path)
            } catch {
                onMovieCaptureError?(.cameraComponentError(reason: .failedToRemoveFileManagerItem))
            }
        }
    }
}
