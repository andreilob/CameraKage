//
//  FocusMode.swift
//  
//
//  Created by Lobont Andrei on 04.06.2023.
//

import Foundation

/// Focus mode of the camera.
public enum FocusMode {
    /// Indicates that the focus should be locked at the lens' current position.
    case locked

    /// Indicates that the device should autofocus once and then change the focus mode to `.locked`.
    case autoFocus

    /// Indicates that the device should automatically focus when needed.
    case continuousAutoFocus
}
