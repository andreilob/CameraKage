//
//  MetadataCamera.swift
//  
//
//  Created by Lobont Andrei on 16.06.2023.
//

import Foundation
import QuartzCore.CALayer

class MetadataCamera: SessionCamera, MetadataCameraInterface {
    private var metadataCapturer: MetadataCapturer

    var onSuccessfullMetadataScan: (([MetadataScanOutput]) -> Void)? {
        didSet {
            metadataCapturer.onSuccessfullMetadataScan = onSuccessfullMetadataScan
        }
    }
    
    init(session: Session,
         videoInput: VideoInput,
         videoLayer: VideoLayer,
         metadataCapturer: MetadataCapturer,
         options: CameraComponentParsedOptions) {
        self.metadataCapturer = metadataCapturer
        super.init(session: session,
                   videoInput: videoInput,
                   videoLayer: videoLayer,
                   options: options)
    }
}
