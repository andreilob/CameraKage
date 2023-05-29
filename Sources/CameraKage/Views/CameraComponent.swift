//
//  CameraComponent.swift
//  CameraKage
//
//  Created by Lobont Andrei on 10.05.2023.
//

import UIKit
import AVFoundation

protocol CameraComponentDelegate: AnyObject {
    func cameraComponent(_ cameraComponent: CameraComponent, didCapturePhoto photo: Data)
    func cameraComponent(_ cameraComponent: CameraComponent, didStartRecordingVideo atFileURL: URL)
    func cameraComponent(_ cameraComponent: CameraComponent, didRecordVideo videoURL: URL)
    func cameraComponent(_ cameraComponent: CameraComponent, didZoomAtScale scale :CGFloat, outOfMaximumScale maxScale: CGFloat)
    func cameraComponent(_ cameraComponent: CameraComponent, didFail withError: CameraError)
}

class CameraComponent: UIView {
    private let sessionComposer: SessionComposable
    private var options: CameraComponentParsedOptions
    private let previewLayer = AVCaptureVideoPreviewLayer()
    private var keyValueObservations = [NSKeyValueObservation]()
    private let photoOutput = AVCapturePhotoOutput()
    private var photoData: Data?
    private var movieFileOutput = AVCaptureMovieFileOutput()
    @objc dynamic private var videoDeviceInput: AVCaptureDeviceInput!
    private var videoDevicePort: AVCaptureInput.Port!
    private var audioDevicePort: AVCaptureInput.Port!
    
    private lazy var pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinch(_:)))
    private var lastZoomFactor: CGFloat = 1.0
    
    private weak var delegate: CameraComponentDelegate?
    
    init(sessionComposer: SessionComposable,
         options: CameraComponentParsedOptions,
         delegate: CameraComponentDelegate?) {
        self.sessionComposer = sessionComposer
        self.options = options
        self.delegate = delegate
        super.init(frame: .zero)
        layer.addSublayer(previewLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Use session init")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer.bounds = frame
        previewLayer.position = CGPoint(x: frame.width / 2, y: frame.height / 2)
    }
    
    func capturePhoto(_ flashMode: AVCaptureDevice.FlashMode,
                      redEyeCorrection: Bool) {
        var photoSettings = AVCapturePhotoSettings()
        photoSettings.flashMode = flashMode
        photoSettings.isAutoRedEyeReductionEnabled = redEyeCorrection
        
        if photoOutput.availablePhotoCodecTypes.contains(.hevc) {
            photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
        }
        if let previewPhotoPixelFormatType = photoSettings.availablePreviewPhotoPixelFormatTypes.first {
            photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPhotoPixelFormatType]
        }
        
        photoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
    
    func startMovieRecording() {
        guard !movieFileOutput.isRecording else { return }
        movieFileOutput.startRecording(to: .makeTempUrl(for: .video), recordingDelegate: self)
    }
    
    func stopMovieRecording() {
        movieFileOutput.stopRecording()
    }
    
    func flipCamera() {
        options.devicePosition = options.devicePosition == .back ? .front : .back
        removeObserver()
        sessionComposer.cleanupSession()
        configureSession()
        addObserver()
    }
    
    func focus(with focusMode: AVCaptureDevice.FocusMode,
               exposureMode: AVCaptureDevice.ExposureMode,
               at devicePoint: CGPoint,
               monitorSubjectAreaChange: Bool) {
        let point = previewLayer.captureDevicePointConverted(fromLayerPoint: devicePoint)
        let device = videoDeviceInput.device
        do {
            try device.lockForConfiguration()
            if device.isFocusPointOfInterestSupported && device.isFocusModeSupported(focusMode) {
                device.focusPointOfInterest = point
                device.focusMode = focusMode
            }
            if device.isExposurePointOfInterestSupported && device.isExposureModeSupported(exposureMode) {
                device.exposurePointOfInterest = point
                device.exposureMode = exposureMode
            }
            device.isSubjectAreaChangeMonitoringEnabled = monitorSubjectAreaChange
            device.unlockForConfiguration()
        } catch {
            notifyDelegateForError(.failedToLockDevice)
        }
    }
    
    func configureSession() {
        defer {
            sessionComposer.commitConfiguration()
        }
        sessionComposer.beginConfiguration()
        
        configureVideoDevice()
        configureAudioDevice()
        configureMovieFileOutput()
        configurePhotoOutput()
        configurePreviewLayer()
        configurePinchGesture()
        addObserver()
    }
    
    private func configureVideoDevice() {
        do {
            guard let videoDevice = AVCaptureDevice.default(options.deviceType,
                                                            for: .video,
                                                            position: options.devicePosition) else {
                notifyDelegateForError(.failedToConfigureVideoDevice)
                return
            }
            let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
            
            guard sessionComposer.canAddInput(videoDeviceInput) else { return }
            sessionComposer.addInputWithNoConnections(videoDeviceInput)
            self.videoDeviceInput = videoDeviceInput
            
            guard let videoPort = videoDeviceInput.ports(for: .video,
                                                         sourceDeviceType: options.deviceType,
                                                         sourceDevicePosition: options.devicePosition).first else {
                notifyDelegateForError(.failedToConfigureVideoDevice)
                return
            }
            self.videoDevicePort = videoPort
        } catch {
            notifyDelegateForError(.failedToConfigureVideoDevice)
        }
    }
    
    private func configureAudioDevice() {
        do {
            guard let audioDevice = AVCaptureDevice.default(for: .audio) else {
                notifyDelegateForError(.failedToConfigureAudioDevice)
                return
            }
            let audioDeviceInput = try AVCaptureDeviceInput(device: audioDevice)
            guard sessionComposer.canAddInput(audioDeviceInput) else {
                notifyDelegateForError(.failedToConfigureAudioDevice)
                return
            }
            sessionComposer.addInputWithNoConnections(audioDeviceInput)
            guard let audioPort = audioDeviceInput.ports(for: .audio,
                                                         sourceDeviceType: .builtInMicrophone,
                                                         sourceDevicePosition: options.devicePosition).first else {
                notifyDelegateForError(.failedToConfigureAudioDevice)
                return
            }
            self.audioDevicePort = audioPort
        } catch {
            notifyDelegateForError(.failedToConfigureAudioDevice)
        }
    }
    
    private func configurePhotoOutput() {
        guard sessionComposer.canAddOutput(photoOutput) else {
            notifyDelegateForError(.failedToAddPhotoOutput)
            return
        }
        sessionComposer.addOutput(photoOutput)
        photoOutput.maxPhotoQualityPrioritization = options.photoQualityPrioritizationMode
        
        let photoConnection = AVCaptureConnection(inputPorts: [videoDevicePort], output: photoOutput)
        guard sessionComposer.canAddConnection(photoConnection) else {
            notifyDelegateForError(.failedToAddPhotoOutput)
            return
        }
        sessionComposer.addConnection(photoConnection)
        
        photoConnection.videoOrientation = options.cameraOrientation
        photoConnection.isVideoMirrored = videoDeviceInput.device.position == .front
    }
    
    private func configureMovieFileOutput() {
        guard sessionComposer.canAddOutput(movieFileOutput) else {
            notifyDelegateForError(.failedToAddMovieOutput)
            return
        }
        sessionComposer.addOutput(movieFileOutput)
        movieFileOutput.maxRecordedDuration = options.maxVideoDuration
        
        let videoConnection = AVCaptureConnection(inputPorts: [videoDevicePort], output: movieFileOutput)
        guard sessionComposer.canAddConnection(videoConnection) else {
            notifyDelegateForError(.failedToAddMovieOutput)
            return
        }
        sessionComposer.addConnection(videoConnection)
        
        videoConnection.isVideoMirrored = videoDeviceInput.device.position == .front
        videoConnection.videoOrientation = options.cameraOrientation
        if videoConnection.isVideoStabilizationSupported {
            videoConnection.preferredVideoStabilizationMode = options.videoStabilizationMode
        }
        
        let audioConnection = AVCaptureConnection(inputPorts: [audioDevicePort], output: movieFileOutput)
        guard sessionComposer.canAddConnection(audioConnection) else {
            notifyDelegateForError(.failedToAddMovieOutput)
            return
        }
        sessionComposer.addConnection(audioConnection)
        
        let availableVideoCodecTypes = movieFileOutput.availableVideoCodecTypes
        if availableVideoCodecTypes.contains(.hevc) {
            movieFileOutput.setOutputSettings([AVVideoCodecKey: AVVideoCodecType.hevc],
                                              for: videoConnection)
        }
    }
    
    private func configurePreviewLayer() {
        sessionComposer.connectPreviewLayer(previewLayer)
        previewLayer.videoGravity = options.videoGravity
        let previewLayerConnection = AVCaptureConnection(inputPort: videoDevicePort, videoPreviewLayer: previewLayer)
        previewLayerConnection.videoOrientation = options.cameraOrientation
        guard sessionComposer.canAddConnection(previewLayerConnection) else {
            notifyDelegateForError(.failedToAddPreviewLayer)
            return
        }
        sessionComposer.addConnection(previewLayerConnection)
    }
    
    private func configurePinchGesture() {
        if options.pinchToZoomEnabled {
            DispatchQueue.main.async {
                self.addGestureRecognizer(self.pinchGestureRecognizer)
            }
        }
    }
    
    private func notifyDelegateForError(_ error: CameraError.CameraComponentErrorReason) {
        delegate?.cameraComponent(self, didFail: .cameraComponentError(reason: error))
    }
    
    @objc private func pinch(_ pinch: UIPinchGestureRecognizer) {
        let device = videoDeviceInput.device
        
        // Return zoom value between the minimum and maximum zoom values
        func minMaxZoom(_ factor: CGFloat) -> CGFloat {
            min(min(max(factor, options.minimumZoomScale),
                    options.maximumZoomScale),
                device.activeFormat.videoMaxZoomFactor)
        }
        
        func update(scale factor: CGFloat) {
            do {
                try device.lockForConfiguration()
                device.videoZoomFactor = factor
                device.unlockForConfiguration()
                delegate?.cameraComponent(self, didZoomAtScale: factor, outOfMaximumScale: options.maximumZoomScale)
            } catch {
                notifyDelegateForError(.failedToLockDevice)
            }
        }
        
        let newScaleFactor = minMaxZoom(pinch.scale * lastZoomFactor)
        switch pinch.state {
        case .began:
            break
        case .changed:
            update(scale: newScaleFactor)
        case .ended:
            lastZoomFactor = minMaxZoom(newScaleFactor)
            update(scale: lastZoomFactor)
        default:
            break
        }
    }
}

// MARK: - Notifications
extension CameraComponent {
    func removeObserver() {
        keyValueObservations.forEach { $0.invalidate() }
        keyValueObservations.removeAll()
    }
    
    private func addObserver() {
        let systemPressureStateObservation = observe(\.self.videoDeviceInput.device.systemPressureState, options: .new) { _, change in
            guard let systemPressureState = change.newValue else { return }
            self.setRecommendedFrameRateRangeForPressureState(systemPressureState: systemPressureState)
        }
        keyValueObservations.append(systemPressureStateObservation)
    }
    
    private func setRecommendedFrameRateRangeForPressureState(systemPressureState: AVCaptureDevice.SystemPressureState) {
        let pressureLevel = systemPressureState.level
        if pressureLevel == .serious || pressureLevel == .critical {
            if !movieFileOutput.isRecording {
                do {
                    try videoDeviceInput.device.lockForConfiguration()
                    videoDeviceInput.device.activeVideoMinFrameDuration = CMTime(value: 1, timescale: 20)
                    videoDeviceInput.device.activeVideoMaxFrameDuration = CMTime(value: 1, timescale: 15)
                    videoDeviceInput.device.unlockForConfiguration()
                } catch {
                    notifyDelegateForError(.failedToLockDevice)
                }
            }
        } else if pressureLevel == .shutdown {
            notifyDelegateForError(.pressureLevelShutdown)
        }
    }
}

// MARK: - AVCapturePhotoCaptureDelegate
extension CameraComponent: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        guard error == nil else {
            notifyDelegateForError(.failedToOutputPhoto(message: error?.localizedDescription))
            return
        }
        photoData = photo.fileDataRepresentation()
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings,
                     error: Error?) {
        guard error == nil, let photoData else {
            notifyDelegateForError(.failedToOutputPhoto(message: error?.localizedDescription))
            return
        }
        delegate?.cameraComponent(self, didCapturePhoto: photoData)
    }
}

// MARK: - AVCaptureFileOutputRecordingDelegate
extension CameraComponent: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput,
                    didStartRecordingTo fileURL: URL,
                    from connections: [AVCaptureConnection]) {
        delegate?.cameraComponent(self, didStartRecordingVideo: fileURL)
    }
    
    func fileOutput(_ output: AVCaptureFileOutput,
                    didFinishRecordingTo outputFileURL: URL,
                    from connections: [AVCaptureConnection],
                    error: Error?) {
        guard error == nil else {
            cleanup(outputFileURL)
            notifyDelegateForError(.failedToOutputMovie(message: error?.localizedDescription))
            return
        }
        delegate?.cameraComponent(self, didRecordVideo: outputFileURL)
    }
    
    private func cleanup(_ url: URL) {
        let path = url.path
        if FileManager.default.fileExists(atPath: path) {
            do {
                try FileManager.default.removeItem(atPath: path)
            } catch {
                notifyDelegateForError(.failedToRemoveFileManagerItem)
            }
        }
    }
}
