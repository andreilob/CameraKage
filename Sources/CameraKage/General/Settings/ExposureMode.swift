//
//  ExposureMode.swift
//  
//
//  Created by Lobont Andrei on 04.06.2023.
//

import Foundation

/// Exposure mode of the camera.
public enum ExposureMode {
    /// Indicates that the exposure should be locked at its current value.
    case locked

    /// Indicates that the device should automatically adjust exposure once and then change the exposure mode to `.locked`.
    case autoExpose

    /// Indicates that the device should automatically adjust exposure when needed.
    case continuousAutoExposure
}
