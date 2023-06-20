//
//  MetadataOutput.swift
//  
//
//  Created by Lobont Andrei on 15.06.2023.
//

import AVFoundation

class MetadataOutput: AVCaptureMetadataOutput, MetadataCapturer {
    private let session: CaptureSession
    
    var onSuccessfullMetadataScan: (([MetadataScanOutput]) -> Void)?
    
    init?(session: CaptureSession,
          metadataTypes: [MetadataType]) {
        self.session = session
        super.init()
        guard configureMetadataOutput(metadataTypes) else { return nil }
    }
    
    private func configureMetadataOutput(_ metadataTypes: [MetadataType]) -> Bool {
        guard session.canAddOutput(self) else { return false }
        session.addOutput(self)
        setMetadataObjectsDelegate(self, queue: .main)
        metadataObjectTypes = metadataTypes.compactMap { $0.avMetadataType }
        return true
    }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate
extension MetadataOutput: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        let outputs = metadataObjects.compactMap { createScanOutput(fromMetadataObject: $0) }
        onSuccessfullMetadataScan?(outputs)
    }
    
    private func createScanOutput(fromMetadataObject object: AVMetadataObject) -> MetadataScanOutput? {
        guard let readableObject = object as? AVMetadataMachineReadableCodeObject,
              let type = MetadataType(avType: object.type),
              let value = readableObject.stringValue else { return nil }
        return MetadataScanOutput(type: type,
                                  bounds: object.bounds,
                                  value: value)
    }
}
