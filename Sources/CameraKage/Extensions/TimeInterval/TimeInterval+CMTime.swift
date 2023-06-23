//
//  TimeInterval+CMTime.swift
//  
//
//  Created by Lobont Andrei on 21.06.2023.
//

import AVFoundation

extension TimeInterval {
    var asCMTime: CMTime {
        CMTime(seconds: self, preferredTimescale: Int32(NSEC_PER_SEC))
    }
}
