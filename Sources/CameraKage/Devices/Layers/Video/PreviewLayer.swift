//
//  PreviewLayer.swift
//  
//
//  Created by Lobont Andrei on 06.06.2023.
//

import AVFoundation

class PreviewLayer: AVCaptureVideoPreviewLayer, VideoLayer {
    private let captureSession: CaptureSession
    private let options: CameraComponentParsedOptions
    private let videoDevice: VideoCaptureDevice
    private(set) var previewLayerConnection: AVCaptureConnection!
    
    init?(session: CaptureSession,
          options: CameraComponentParsedOptions,
          videoDevice: VideoCaptureDevice) {
        self.captureSession = session
        self.options = options
        self.videoDevice = videoDevice
        super.init(sessionWithNoConnection: session)
        guard configurePreviewLayer() else { return nil }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func embedPreviewLayer(in layer: CALayer) {
        layer.addSublayer(self)
    }
    
    func setPreviewLayerFrame(_ frame: CGRect) {
        bounds = frame
        position = CGPoint(x: frame.width / 2, y: frame.height / 2)
    }
    
    func reloadPreviewLayer() throws {
        let containsConnection = session?.connections.contains(where: { connection in
            previewLayerConnection == connection
        })
        if let containsConnection, containsConnection {
            session?.removeConnection(previewLayerConnection)
        }
        if !configurePreviewLayer() {
            throw CameraError.cameraComponentError(reason: .failedToAddPreviewLayer)
        }
    }
    
    private func configurePreviewLayer() -> Bool {
        videoGravity = options.videoGravity.avLayerVideoGravity
        let previewLayerConnection = AVCaptureConnection(inputPort: videoDevice.videoDevicePort, videoPreviewLayer: self)
        previewLayerConnection.videoOrientation = options.cameraOrientation.avVideoOrientationMode
        guard captureSession.canAddConnection(previewLayerConnection) else { return false }
        captureSession.addConnection(previewLayerConnection)
        self.previewLayerConnection = previewLayerConnection
        return true
    }
}
