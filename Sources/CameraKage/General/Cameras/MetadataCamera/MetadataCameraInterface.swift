//
//  MetadataCameraInterface.swift
//  
//
//  Created by Lobont Andrei on 16.06.2023.
//

import Foundation
import QuartzCore.CALayer

protocol MetadataCameraInterface: SessionCameraInterface {
    var onSuccessfullMetadataScan: (([MetadataScanOutput]) -> Void)? { get set }
}
