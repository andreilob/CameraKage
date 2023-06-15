//
//  VideoStabilizationMode.swift
//  
//
//  Created by Lobont Andrei on 14.06.2023.
//

import Foundation

public enum VideoStabilizationMode {
    /// Provides no video stabilization
    case off
    
    /// Indicates that video should be stabilized using the standard video stabilization algorithm. Standard video stabilization has a reduced field of view. Enabling video stabilization may introduce additional latency into the video capture pipeline.
    case standard
    
    /// Indicates that video should be stabilized using the cinematic stabilization algorithm for more dramatic results. Cinematic video stabilization has a reduced field of view compared to standard video stabilization. Enabling cinematic video stabilization introduces much more latency into the video capture pipeline than standard video stabilization and consumes significantly more system memory. Use narrow or identical min and max frame durations in conjunction with this mode.
    case cinematic
    
    /// Indicates that the video should be stabilized using the extended cinematic stabilization algorithm. Enabling extended cinematic stabilization introduces longer latency into the video capture pipeline compared to the `.cinematic` mode and consumes more memory, but yields improved stability. It is recommended to use identical or similar min and max frame durations in conjunction with this mode.
    case cinematicExtended
    
    /// The camera device will determine the best mode to be used.
    case auto
}
