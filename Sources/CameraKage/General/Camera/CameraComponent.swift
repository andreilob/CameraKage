//
//  CameraComponent.swift
//  CameraKage
//
//  Created by Lobont Andrei on 10.05.2023.
//

import UIKit
import AVFoundation

class CameraComponent: UIView {
    private let camera: Camera
    private var photoData: Data?
    private var lastZoomFactor: CGFloat = 1.0
    private lazy var pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinch(_:)))
    
    var isRecording: Bool { camera.isRecording }

    weak var delegate: CameraComponentDelegate?
    
    init(camera: Camera) {
        self.camera = camera
        super.init(frame: .zero)
        layer.addSublayer(camera.previewLayer)
        configurePinchGesture()
        configureSystemPressureHandler()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Use camera init")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        camera.previewLayer.bounds = frame
        camera.previewLayer.position = CGPoint(x: frame.width / 2, y: frame.height / 2)
    }
    
    func capturePhoto(_ flashMode: FlashMode,
                      redEyeCorrection: Bool) {
        camera.capturePhoto(flashMode, redEyeCorrection: redEyeCorrection, delegate: self)
    }
    
    func startMovieRecording() {
        camera.startMovieRecording(delegate: self)
    }
    
    func stopMovieRecording() {
        camera.stopMovieRecording()
    }
    
    func flipCamera() {
        do {
            try camera.flipCamera()
            DispatchQueue.main.async {
                self.layer.addSublayer(self.camera.previewLayer)
                self.layoutSubviews()
            }
        } catch let error as CameraError {
            notifyDelegateForError(error)
        } catch {
            notifyDelegateForError(.cameraComponentError(reason: .failedToComposeCamera))
        }
    }
    
    func focus(with focusMode: FocusMode,
               exposureMode: ExposureMode,
               at devicePoint: CGPoint,
               monitorSubjectAreaChange: Bool) {
        do {
            try camera.focus(with: focusMode,
                             exposureMode: exposureMode,
                             at: devicePoint,
                             monitorSubjectAreaChange: monitorSubjectAreaChange)
        } catch let error as CameraError {
            notifyDelegateForError(error)
        } catch {
            notifyDelegateForError(.cameraComponentError(reason: .failedToLockDevice))
        }
    }
    
    private func configurePinchGesture() {
        if camera.allowsPinchZoom {
            DispatchQueue.main.async {
                self.addGestureRecognizer(self.pinchGestureRecognizer)
            }
        }
    }
        
    private func configureSystemPressureHandler() {
        camera.onCameraSystemPressureError = { [weak self] error in
            guard let self else { return }
            self.notifyDelegateForError(error)
        }
    }
    
    private func notifyDelegateForError(_ error: CameraError) {
        delegate?.cameraComponent(self, didFail: error)
    }
    
    @objc private func pinch(_ pinch: UIPinchGestureRecognizer) {
        let newScaleFactor = camera.minMaxZoom(pinch.scale * lastZoomFactor)
        do {
            switch pinch.state {
            case .changed:
                try camera.zoom(atScale: newScaleFactor)
            case .ended:
                lastZoomFactor = camera.minMaxZoom(newScaleFactor)
                try camera.zoom(atScale: lastZoomFactor)
            default:
                break
            }
        } catch let error as CameraError {
            notifyDelegateForError(error)
        } catch {
            notifyDelegateForError(.cameraComponentError(reason: .failedToLockDevice))
        }
    }
}

// MARK: - AVCapturePhotoCaptureDelegate
extension CameraComponent: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        guard error == nil else {
            notifyDelegateForError(.cameraComponentError(reason: .failedToOutputPhoto(message: error?.localizedDescription)))
            return
        }
        photoData = photo.fileDataRepresentation()
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings,
                     error: Error?) {
        guard error == nil, let photoData else {
            notifyDelegateForError(.cameraComponentError(reason: .failedToOutputPhoto(message: error?.localizedDescription)))
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
            notifyDelegateForError(.cameraComponentError(reason: .failedToOutputMovie(message: error?.localizedDescription)))
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
                notifyDelegateForError(.cameraComponentError(reason: .failedToRemoveFileManagerItem))
            }
        }
    }
}
