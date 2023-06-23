//
//  MediaType+AVFoundation.swift
//  
//
//  Created by Lobont Andrei on 07.06.2023.
//

import AVFoundation

extension MediaType {
    var avMediaType: AVMediaType {
        switch self {
        case .audio: return .audio
        case .video: return .video
        }
    }
}
