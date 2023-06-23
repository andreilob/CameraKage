//
//  LayerVideoGravity+AVFoundation.swift
//  
//
//  Created by Lobont Andrei on 14.06.2023.
//

import AVFoundation

extension LayerVideoGravity {
    var avLayerVideoGravity: AVLayerVideoGravity {
        switch self {
        case .resizeAspect: return .resizeAspect
        case .resizeAspectFill: return .resizeAspectFill
        case .resize: return .resize
        }
    }
}
