//
//  MetadataOutputMock.swift
//  
//
//  Created by Lobont Andrei on 20.06.2023.
//

import Foundation
@testable import CameraKage

class MetadataOutputMock: MetadataCapturer {
    var onSuccessfullMetadataScan: (([MetadataScanOutput]) -> Void)?
    
}
