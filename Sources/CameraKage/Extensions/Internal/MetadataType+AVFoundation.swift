//
//  MetadataType+AVFoundation.swift
//  
//
//  Created by Lobont Andrei on 19.06.2023.
//

import AVFoundation

extension MetadataType {
    init?(avType: AVMetadataObject.ObjectType) {
        switch avType {
        case .upce: self = .upce
        case .code39: self = .code39
        case .code39Mod43: self = .code39Mod43
        case .ean13: self = .ean13
        case .ean8: self = .ean8
        case .code93: self = .code93
        case .code128: self = .code128
        case .pdf417: self = .pdf417
        case .qr: self = .qr
        case .aztec: self = .aztec
        case .interleaved2of5: self = .interleaved2of5
        case .itf14: self = .itf14
        case .dataMatrix: self = .dataMatrix
        default: return nil
        }
    }
    
    var avMetadataType: AVMetadataObject.ObjectType {
        switch self {
        case .upce: return .upce
        case .code39: return .code39
        case .code39Mod43: return .code39Mod43
        case .ean13: return .ean13
        case .ean8: return .ean8
        case .code93: return .code93
        case .code128: return .code128
        case .pdf417: return .pdf417
        case .qr: return .qr
        case .aztec: return .aztec
        case .interleaved2of5: return .interleaved2of5
        case .itf14: return .itf14
        case .dataMatrix: return .dataMatrix
        }
    }
}
