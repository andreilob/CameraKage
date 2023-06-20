//
//  MetadataCameraView.swift
//  
//
//  Created by Lobont Andrei on 16.06.2023.
//

import UIKit

public class MetadataCameraView: SessionCameraView {
    private var metadataCamera: MetadataCameraInterface
    
    init(metadataCamera: MetadataCameraInterface) {
        self.metadataCamera = metadataCamera
        super.init(sessionCamera: metadataCamera)
        setupMetadataCapturer()
    }
    
    init(metadataCamera: MetadataCameraInterface, sessionQueue: DispatchQueue) {
        self.metadataCamera = metadataCamera
        super.init(sessionCamera: metadataCamera, sessionQueue: sessionQueue)
        setupMetadataCapturer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Coder not usable.")
    }
    
    /**
     Register a delegate to receive notifications regarding the camera session.
     
     - parameter delegate: The object that will receive the notifications.
     */
    public func registerDelegate(_ delegate: any MetadataCameraDelegate) {
        super.registerDelegate(delegate)
    }
    
    /**
     Unregisters a delegate from receiving notifications.
     
     - parameter delegate: The object to be removed.
     */
    public func unregisterDelegate(_ delegate: any MetadataCameraDelegate) {
        super.unregisterDelegate(delegate)
    }
    
    /**
     Configures the phone's torch in case the scanner need to be used in the dark.
     
     - parameter torchOption: The torch mode to be used.
     */
    public func configureTorchSetting(torchOption: FlashMode) {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            do {
                try self.metadataCamera.configureFlash(torchOption)
            } catch let error as CameraError {
                self.invokeDelegates { $0.cameraDidEncounterError(error: error) }
            } catch {
                self.invokeDelegates { $0.cameraDidEncounterError(error: .cameraComponentError(reason: .torchModeNotSupported)) }
            }
        }
    }
    
    private func setupMetadataCapturer() {
        metadataCamera.onSuccessfullMetadataScan = { [weak self] metadata in
            guard let self else { return }
            self.invokeDelegates { $0.cameraDidScanMetadataInfo(metadata: metadata) }
        }
    }
    
    private func invokeDelegates(_ execute: @escaping (any MetadataCameraDelegate) -> Void) {
        metadataCamera.delegateQueue.async { [weak self] in
            guard let self else { return }
            self.delegatesManager.invokeDelegates { delegate in
                guard let delegate = delegate as? (any MetadataCameraDelegate) else { return }
                execute(delegate)
            }
        }
    }
}
