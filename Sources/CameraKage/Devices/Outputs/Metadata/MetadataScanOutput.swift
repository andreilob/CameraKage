//
//  MetadataScanOutput.swift
//  
//
//  Created by Lobont Andrei on 19.06.2023.
//

import Foundation

public struct MetadataScanOutput {
    /// The value of this property is an MetadataType representing the type of the metadata object. Clients inspecting a collection of metadata objects can use this property to filter objects with a matching type.
    let type: MetadataType
    
    /// The value of this property is a CGRect representing the bounding rectangle of the object with respect to the picture in which it resides. The rectangle's origin is top left. If the metadata originates from video, bounds may be expressed as scalar values from 0. - 1. If the original video has been scaled down, the bounds of the metadata object still are meaningful. This property may return CGRectZero if the metadata has no bounds.
    let bounds: CGRect
    
    /// The value of this property is a String created by decoding the binary payload according to the format of the machine readable code.
    let value: String
}
