//
//  Camera.swift
//  
//
//  Created by Lobont Andrei on 30.05.2023.
//

import AVFoundation

class Camera: NSObject {
    let session: AVCaptureMultiCamSession
    let options: CameraComponentParsedOptions
    
    @objc dynamic var videoDevice: AVCaptureDevice!
    @objc dynamic var videoDeviceInput: AVCaptureDeviceInput!
    var videoDevicePort: AVCaptureDeviceInput.Port!
    
    var audioDevice: AVCaptureDevice!
    var audioDeviceInput: AVCaptureDeviceInput!
    var audioDevicePort: AVCaptureDeviceInput.Port!
    
    var photoOutput: AVCapturePhotoOutput!
    var photoVideoOutputConnection: AVCaptureConnection!
    
    var movieOutput: AVCaptureMovieFileOutput!
    var movieVideoOutputConnection: AVCaptureConnection!
    var movieAudioOutputConnection: AVCaptureConnection!
    
    var previewLayer: AVCaptureVideoPreviewLayer!
    var previewLayerConnection: AVCaptureConnection!
    
    var allowsPinchZoom: Bool { options.pinchToZoomEnabled }
    var onCameraSystemPressureError: ((CameraError) -> Void)?
    var isRecording: Bool { movieOutput.isRecording }
    
    private var keyValueObservations = [NSKeyValueObservation]()
    
    init?(session: AVCaptureMultiCamSession,
          options: CameraComponentParsedOptions) throws {
        self.session = session
        self.options = options
        super.init()
        do {
            try configureSession()
        } catch let error as CameraError {
            throw error
        } catch {
            throw CameraError.cameraComponentError(reason: .failedToComposeCamera)
        }
    }
    
    deinit {
        removeObserver()
    }
    
    func capturePhoto(_ flashMode: FlashMode,
                      redEyeCorrection: Bool,
                      delegate: AVCapturePhotoCaptureDelegate) {
        var photoSettings = AVCapturePhotoSettings()
        photoSettings.flashMode = flashMode.avFlashOption
        photoSettings.isAutoRedEyeReductionEnabled = redEyeCorrection
        
        if photoOutput.availablePhotoCodecTypes.contains(.hevc) {
            photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
        }
        if let previewPhotoPixelFormatType = photoSettings.availablePreviewPhotoPixelFormatTypes.first {
            photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPhotoPixelFormatType]
        }
        
        photoOutput.capturePhoto(with: photoSettings, delegate: delegate)
    }
    
    func startMovieRecording(delegate: AVCaptureFileOutputRecordingDelegate) {
        guard !movieOutput.isRecording else { return }
        movieOutput.startRecording(to: .makeTempUrl(for: .video), recordingDelegate: delegate)
    }
    
    func stopMovieRecording() {
        movieOutput.stopRecording()
    }
    
    func focus(with focusMode: FocusMode,
               exposureMode: ExposureMode,
               at devicePoint: CGPoint,
               monitorSubjectAreaChange: Bool) throws {
        let point = previewLayer.captureDevicePointConverted(fromLayerPoint: devicePoint)
        do {
            try videoDevice.lockForConfiguration()
            if videoDevice.isFocusPointOfInterestSupported &&
                videoDevice.isFocusModeSupported(focusMode.avFocusOption) {
                videoDevice.focusPointOfInterest = point
                videoDevice.focusMode = focusMode.avFocusOption
            }
            if videoDevice.isExposurePointOfInterestSupported &&
                videoDevice.isExposureModeSupported(exposureMode.avExposureOption) {
                videoDevice.exposurePointOfInterest = point
                videoDevice.exposureMode = exposureMode.avExposureOption
            }
            videoDevice.isSubjectAreaChangeMonitoringEnabled = monitorSubjectAreaChange
            videoDevice.unlockForConfiguration()
        } catch {
            throw CameraError.cameraComponentError(reason: .failedToLockDevice)
        }
    }
    
    func flipCamera() throws {
        do {
            options.devicePosition = options.devicePosition == .back ? .front : .back
            removeObserver()
            removeDevices()
            try configureSession()
            addObserver()
        } catch let error as CameraError {
            throw error
        } catch {
            throw CameraError.cameraComponentError(reason: .failedToComposeCamera)
        }
    }
    
    func zoom(atScale: CGFloat) throws {
        do {
            try videoDevice.lockForConfiguration()
            videoDevice.videoZoomFactor = atScale
            videoDevice.unlockForConfiguration()
        } catch {
            throw CameraError.cameraComponentError(reason: .failedToLockDevice)
        }
    }
    
    func minMaxZoom(_ factor: CGFloat) -> CGFloat {
        let maxFactor = max(factor, options.minimumZoomScale)
        return min(min(maxFactor, options.maximumZoomScale), videoDevice.activeFormat.videoMaxZoomFactor)
    }
    
    private func configureSession() throws {
        defer {
            session.commitConfiguration()
        }
        session.beginConfiguration()
        
        guard configureVideoDevice() else {
            throw CameraError.cameraComponentError(reason: .failedToConfigureVideoDevice)
        }
        guard configureAudioDevice() else {
            throw CameraError.cameraComponentError(reason: .failedToConfigureAudioDevice)
        }
        guard configureMovieFileOutput() else {
            throw CameraError.cameraComponentError(reason: .failedToAddMovieOutput)
        }
        guard configurePhotoOutput() else {
            throw CameraError.cameraComponentError(reason: .failedToAddPhotoOutput)
        }
        guard configurePreviewLayer() else {
            throw CameraError.cameraComponentError(reason: .failedToAddPreviewLayer)
        }
    }
    
    private func configureVideoDevice() -> Bool {
        do {
            guard let videoDevice = AVCaptureDevice.default(options.deviceType,
                                                            for: .video,
                                                            position: options.devicePosition) else { return false }
            self.videoDevice = videoDevice
            let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
            guard session.canAddInput(videoDeviceInput) else { return false }
            session.addInputWithNoConnections(videoDeviceInput)
            self.videoDeviceInput = videoDeviceInput
            
            guard let videoPort = videoDeviceInput.ports(for: .video,
                                                         sourceDeviceType: options.deviceType,
                                                         sourceDevicePosition: options.devicePosition).first else { return false }
            self.videoDevicePort = videoPort
            return true
        } catch {
            return false
        }
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
                                                         sourceDevicePosition: options.devicePosition).first else { return false }
            self.audioDevicePort = audioPort
            return true
        } catch {
            return false
        }
    }
    
    private func configurePhotoOutput() -> Bool {
        let photoOutput = AVCapturePhotoOutput()
        guard session.canAddOutput(photoOutput) else { return false }
        session.addOutputWithNoConnections(photoOutput)
        photoOutput.maxPhotoQualityPrioritization = options.photoQualityPrioritizationMode
        self.photoOutput = photoOutput
        
        let photoConnection = AVCaptureConnection(inputPorts: [videoDevicePort], output: photoOutput)
        guard session.canAddConnection(photoConnection) else { return false }
        session.addConnection(photoConnection)
        photoConnection.videoOrientation = options.cameraOrientation
        photoConnection.isVideoMirrored = options.devicePosition == .front
        self.photoVideoOutputConnection = photoConnection
        
        return true
    }
    
    private func configureMovieFileOutput() -> Bool {
        let movieFileOutput = AVCaptureMovieFileOutput()
        guard session.canAddOutput(movieFileOutput) else { return false }
        session.addOutputWithNoConnections(movieFileOutput)
        movieFileOutput.maxRecordedDuration = options.maxVideoDuration
        self.movieOutput = movieFileOutput
        
        let videoConnection = AVCaptureConnection(inputPorts: [videoDevicePort], output: movieFileOutput)
        guard session.canAddConnection(videoConnection) else { return false }
        session.addConnection(videoConnection)
        videoConnection.isVideoMirrored = options.devicePosition == .front
        videoConnection.videoOrientation = options.cameraOrientation
        if videoConnection.isVideoStabilizationSupported {
            videoConnection.preferredVideoStabilizationMode = options.videoStabilizationMode
        }
        self.movieVideoOutputConnection = videoConnection
        
        let audioConnection = AVCaptureConnection(inputPorts: [audioDevicePort], output: movieFileOutput)
        guard session.canAddConnection(audioConnection) else { return false }
        session.addConnection(audioConnection)
        let availableVideoCodecTypes = movieFileOutput.availableVideoCodecTypes
        if availableVideoCodecTypes.contains(.hevc) {
            movieFileOutput.setOutputSettings([AVVideoCodecKey: AVVideoCodecType.hevc],
                                              for: videoConnection)
        }
        self.movieAudioOutputConnection = audioConnection
        
        return true
    }
    
    private func configurePreviewLayer() -> Bool {
        let previewLayer = AVCaptureVideoPreviewLayer(sessionWithNoConnection: session)
        previewLayer.videoGravity = options.videoGravity
        self.previewLayer = previewLayer
        
        let previewLayerConnection = AVCaptureConnection(inputPort: videoDevicePort, videoPreviewLayer: previewLayer)
        previewLayerConnection.videoOrientation = options.cameraOrientation
        guard session.canAddConnection(previewLayerConnection) else { return false }
        session.addConnection(previewLayerConnection)
        self.previewLayerConnection = previewLayerConnection
        
        return true
    }
    
    private func removeDevices() {
        defer {
            session.commitConfiguration()
        }
        session.beginConfiguration()
        
        session.outputs.forEach { session.removeOutput($0) }
        session.inputs.forEach { session.removeInput($0) }
        session.connections.forEach { session.removeConnection($0) }
    }
}

// MARK: - Notifications
extension Camera {
    func removeObserver() {
        keyValueObservations.forEach { $0.invalidate() }
        keyValueObservations.removeAll()
    }
    
    private func addObserver() {
        let systemPressureStateObservation = observe(\.videoDevice.systemPressureState, options: .new) { _, change in
            guard let systemPressureState = change.newValue else { return }
            self.setRecommendedFrameRateRangeForPressureState(systemPressureState: systemPressureState)
        }
        keyValueObservations.append(systemPressureStateObservation)
    }
    
    private func setRecommendedFrameRateRangeForPressureState(systemPressureState: AVCaptureDevice.SystemPressureState) {
        let pressureLevel = systemPressureState.level
        if pressureLevel == .serious || pressureLevel == .critical {
            if !movieOutput.isRecording {
                do {
                    try videoDevice.lockForConfiguration()
                    videoDevice.activeVideoMinFrameDuration = CMTime(value: 1, timescale: 20)
                    videoDevice.activeVideoMaxFrameDuration = CMTime(value: 1, timescale: 15)
                    videoDevice.unlockForConfiguration()
                } catch {
                    onCameraSystemPressureError?(.cameraComponentError(reason: .failedToLockDevice))
                }
            }
        } else if pressureLevel == .shutdown {
            onCameraSystemPressureError?(.cameraComponentError(reason: .pressureLevelShutdown))
        }
    }
}
