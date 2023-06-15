//
//  MovieOutput.swift
//  
//
//  Created by Lobont Andrei on 05.06.2023.
//

import AVFoundation

class MovieOutput: AVCaptureMovieFileOutput, MovieCapturer {
    private let session: CaptureSession
    private let options: CameraComponentParsedOptions
    private let videoDevice: VideoCaptureDevice
    private let audioDevice: AudioCaptureDevice
    private(set) var videoPortConnection: AVCaptureConnection?
    private(set) var audioPortConnection: AVCaptureConnection?
    
    var onMovieCaptureSuccess: ((URL) -> Void)?
    var onMovieCaptureStart: ((URL) -> Void)?
    var onMovieCaptureError: ((CameraError) -> Void)?
    
    init?(forSession session: CaptureSession,
          andOptions options: CameraComponentParsedOptions,
          videoDevice: VideoCaptureDevice,
          audioDevice: AudioCaptureDevice) {
        self.session = session
        self.options = options
        self.videoDevice = videoDevice
        self.audioDevice = audioDevice
        super.init()
        guard configureMovieFileOutput() else { return nil }
    }
    
    func startMovieRecording() {
        guard !isRecording else { return }
        startRecording(to: .makeTempUrl(for: .video), recordingDelegate: self)
    }
    
    func stopMovieRecording() {
        stopRecording()
    }
    
    func handleFlip() throws {
        session.removeOutput(self)
        let containsVideoConnection = session.connections.contains(where: { connection in
            videoPortConnection == connection
        })
        let containsAudioConnection = session.connections.contains(where: { connection in
            audioPortConnection == connection
        })
        if let videoPortConnection, containsVideoConnection {
            session.removeConnection(videoPortConnection)
        }
        if let audioPortConnection, containsAudioConnection {
            session.removeConnection(audioPortConnection)
        }
        if !configureMovieFileOutput() {
            throw CameraError.cameraComponentError(reason: .failedToAddMovieOutput)
        }
    }
    
    private func configureMovieFileOutput() -> Bool {
        guard session.canAddOutput(self) else { return false }
        session.addOutputWithNoConnections(self)
        maxRecordedDuration = CMTime(seconds: options.maxVideoDuration, preferredTimescale: .max)
        
        let videoConnection = AVCaptureConnection(inputPorts: [videoDevice.videoDevicePort], output: self)
        guard session.canAddConnection(videoConnection) else { return false }
        session.addConnection(videoConnection)
        videoConnection.isVideoMirrored = videoDevice.isVideoMirrored
        videoConnection.videoOrientation = options.cameraOrientation.avVideoOrientationMode
        if videoConnection.isVideoStabilizationSupported {
            videoConnection.preferredVideoStabilizationMode = options.videoStabilizationMode.avVideoStabilizationMode
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
