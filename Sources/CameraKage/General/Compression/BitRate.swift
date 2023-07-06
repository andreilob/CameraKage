//
//  BitRate.swift
//  
//
//  Created by Lobont Andrei on 04.07.2023.
//

import Foundation

/**
 Video bitrate is essentially any video data that is being transferred at any given moment. A high bitrate is essential for streamers, as it is what defines the quality of a video. Bitrate is a measurement of the amount of data used to encode a single second of video.
 */
public enum BitRate: Int64 {
    /// 1000 kbps
    case low = 1000000
    /// 2500 kbps
    case medium = 2500000
    /// 4000 kbps
    case high = 4000000
    /// 6000 kbps
    case veryHigh = 6000000
    /// 8000 kbps
    case excellent = 8000000
}
