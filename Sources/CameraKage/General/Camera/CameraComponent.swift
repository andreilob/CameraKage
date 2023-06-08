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
    private lazy var pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinch(_:)))
    
    var isRecording: Bool { camera.isRecording }
    
    init(camera: Camera) {
        self.camera = camera
        super.init(frame: .zero)
        camera.embedPreviewLayer(in: layer)
        configurePinchGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Use camera init")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        camera.setPreviewLayerFrame(frame: frame)
    }
    
    func capturePhoto(_ flashMode: FlashMode, redEyeCorrection: Bool) {
        camera.capturePhoto(flashMode, redEyeCorrection: redEyeCorrection)
    }
    
    func startMovieRecording(_ flashMode: FlashMode) {
        camera.startMovieRecording(flashMode)
    }
    
    func stopMovieRecording() {
        camera.stopMovieRecording()
    }
    
    func flipCamera() {
        camera.flipCamera()
        DispatchQueue.main.async {
            self.camera.embedPreviewLayer(in: self.layer)
            self.layoutSubviews()
        }
    }
    
    func focus(with focusMode: FocusMode,
               exposureMode: ExposureMode,
               at devicePoint: CGPoint,
               monitorSubjectAreaChange: Bool) {
        camera.focus(with: focusMode,
                         exposureMode: exposureMode,
                         at: devicePoint,
                         monitorSubjectAreaChange: monitorSubjectAreaChange)
    }
    
    private func configurePinchGesture() {
        if camera.allowsPinchZoom {
            DispatchQueue.main.async {
                self.addGestureRecognizer(self.pinchGestureRecognizer)
            }
        }
    }
    
    @objc private func pinch(_ pinch: UIPinchGestureRecognizer) {
        camera.zoom(atScale: pinch.scale)
    }
}
