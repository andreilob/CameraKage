//
//  PreviewLayer.swift
//  
//
//  Created by Lobont Andrei on 06.06.2023.
//

import AVFoundation

class PreviewLayer: AVCaptureVideoPreviewLayer {
    private(set) var previewLayerConnection: AVCaptureConnection!
    
    func configurePreviewLayer(forSession session: CaptureSession,
                               andOptions options: CameraComponentParsedOptions,
                               videoDevice: VideoCaptureDevice) -> Bool {
        setSessionWithNoConnection(session)
        videoGravity = options.videoGravity
        
        let previewLayerConnection = AVCaptureConnection(inputPort: videoDevice.videoDevicePort, videoPreviewLayer: self)
        previewLayerConnection.videoOrientation = options.cameraOrientation
        guard session.canAddConnection(previewLayerConnection) else { return false }
        session.addConnection(previewLayerConnection)
        self.previewLayerConnection = previewLayerConnection
        
        return true
    }
}
