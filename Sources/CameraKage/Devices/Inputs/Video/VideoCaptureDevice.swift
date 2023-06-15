//
//  VideoCaptureDevice.swift
//  
//
//  Created by Lobont Andrei on 06.06.2023.
//

import AVFoundation

class VideoCaptureDevice: NSObject, VideoInput {
    private let session: CaptureSession
    private let options: CameraComponentParsedOptions
    @objc private(set) dynamic var videoDevice: AVCaptureDevice!
    @objc private(set) dynamic var videoDeviceInput: AVCaptureDeviceInput!
    private(set) var videoDevicePort: AVCaptureDeviceInput.Port!
    
    private var isFlipped = false
    private var keyValueObservations = [NSKeyValueObservation]()
    
    var onVideoDeviceError: ((CameraError) -> Void)?
    var isVideoMirrored: Bool {
        let camera = isFlipped ? options.flipCameraDevice : options.cameraDevice
        return camera.avDevicePosition == .front
    }
    
    init?(session: CaptureSession,
          options: CameraComponentParsedOptions) {
        self.session = session
        self.options = options
        super.init()
        guard configureVideoDevice() else { return nil }
        addObservers()
    }
    
    deinit {
        removeObservers()
    }
    
    func flip() throws {
        session.removeInput(videoDeviceInput)
        isFlipped.toggle()
        if !configureVideoDevice() {
            throw CameraError.cameraComponentError(reason: .failedToConfigureVideoDevice)
        }
    }
    
    func focus(focusMode: FocusMode, exposureMode: ExposureMode, point: CGPoint, monitorSubjectAreaChange: Bool) throws {
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
    
    func zoom(atScale: CGFloat) throws {
        do {
            try videoDevice.lockForConfiguration()
            videoDevice.videoZoomFactor = atScale
            videoDevice.unlockForConfiguration()
        } catch {
            throw CameraError.cameraComponentError(reason: .failedToLockDevice)
        }
    }
    
    func minMaxZoom(_ factor: CGFloat, options: CameraComponentParsedOptions) -> CGFloat {
        min(min(max(factor, options.minimumZoomScale), options.maximumZoomScale), videoDevice.activeFormat.videoMaxZoomFactor)
    }
    
    func configureFlash(_ flashMode: FlashMode) throws {
        guard videoDevice.isTorchModeSupported(flashMode.avTorchModeOption),
              videoDevice.isTorchAvailable,
              videoDevice.torchMode != flashMode.avTorchModeOption else {
            if flashMode == .off {
                return
            } else {
                throw CameraError.cameraComponentError(reason: .torchModeNotSupported)
            }
        }
        do {
            try videoDevice.lockForConfiguration()
            videoDevice.torchMode = flashMode.avTorchModeOption
            videoDevice.unlockForConfiguration()
        } catch {
            throw CameraError.cameraComponentError(reason: .failedToLockDevice)
        }
    }
    
    private func configureVideoDevice() -> Bool {
        do {
            let camera = isFlipped ? options.flipCameraDevice : options.cameraDevice
            guard let videoDevice = AVCaptureDevice.default(camera.avDeviceType,
                                                            for: .video,
                                                            position: camera.avDevicePosition) else { return false }
            self.videoDevice = videoDevice
            let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
            guard session.canAddInput(videoDeviceInput) else { return false }
            session.addInputWithNoConnections(videoDeviceInput)
            self.videoDeviceInput = videoDeviceInput
            
            guard let videoPort = videoDeviceInput.ports(for: .video,
                                                         sourceDeviceType: camera.avDeviceType,
                                                         sourceDevicePosition: camera.avDevicePosition).first else { return false }
            self.videoDevicePort = videoPort
            return true
        } catch {
            return false
        }
    }
    
    func removeObservers() {
        keyValueObservations.forEach { $0.invalidate() }
        keyValueObservations.removeAll()
    }
    
    func addObservers() {
        let systemPressureStateObservation = observe(\.videoDevice.systemPressureState, options: .new) { _, change in
            guard let systemPressureState = change.newValue else { return }
            self.setRecommendedFrameRateRangeForPressureState(systemPressureState: systemPressureState)
        }
        keyValueObservations.append(systemPressureStateObservation)
    }
    
    private func setRecommendedFrameRateRangeForPressureState(systemPressureState: AVCaptureDevice.SystemPressureState) {
        let pressureLevel = systemPressureState.level
        if pressureLevel == .serious || pressureLevel == .critical {
            do {
                try videoDevice.lockForConfiguration()
                videoDevice.activeVideoMinFrameDuration = CMTime(value: 1, timescale: 20)
                videoDevice.activeVideoMaxFrameDuration = CMTime(value: 1, timescale: 15)
                videoDevice.unlockForConfiguration()
            } catch {
                onVideoDeviceError?(.cameraComponentError(reason: .failedToLockDevice))
            }
        } else if pressureLevel == .shutdown {
            onVideoDeviceError?(.cameraComponentError(reason: .pressureLevelShutdown))
        }
    }
}
