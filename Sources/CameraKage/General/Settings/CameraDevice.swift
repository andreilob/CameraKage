//
//  CameraDevice.swift
//  
//
//  Created by Lobont Andrei on 05.06.2023.
//

import Foundation

public enum CameraDevice {
    ///  A built-in front side wide angle camera device. These devices are suitable for general purpose use.
    case frontCamera
    
    ///  A built-in back side wide angle camera device. These devices are suitable for general purpose use.
    case backWideCamera
    
    ///  A built-in camera device with a longer focal length than a wide angle camera. Not available on all phones.
    case backTelephotoCamera
    
    ///  A built-in camera device with a shorter focal length than a wide angle camera. Not available on all phones.
    case backUltraWideCamera
    
    /// A device that consists of two fixed focal length cameras, one wide and one telephoto. Not available on all phones.
    /// A device of this device type supports the following features:
    /// - Auto switching from one camera to the other when zoom factor, light level, and focus position allow this.
    /// - Higher quality zoom for still captures by fusing images from both cameras.
    /// - Delivery of photos from constituent devices (wide and telephoto cameras) via a single photo capture request.
    /// Even when locked, exposure duration, ISO, aperture, white balance gains, or lens position may change when the device switches from one camera to the other. The overall exposure, white balance, and focus position however should be consistent.
    case backDualCamera
    
    ///  A device that consists of two fixed focal length cameras, one ultra wide and one wide angle. Not available on all phones.
    /// A device of this device type supports the following features:
    /// - Auto switching from one camera to the other when zoom factor, light level, and focus position allow this.
    /// - Delivery of photos from constituent devices (ultra wide and wide) via a single photo capture request.
    
    /// Even when locked, exposure duration, ISO, aperture, white balance gains, or lens position may change when the device switches from one camera to the other. The overall exposure, white balance, and focus position however should be consistent.
    case backWideDualCamera
    
    /// A device that consists of three fixed focal length cameras, one ultra wide, one wide angle, and one telephoto. Not available on all phones.
    /// A device of this device type supports the following features:
    /// - Auto switching from one camera to the other when zoom factor, light level, and focus position allow this.
    /// - Delivery of photos from constituent devices (ultra wide, wide and telephoto cameras) via a single photo capture request.
    /// Even when locked, exposure duration, ISO, aperture, white balance gains, or lens position may change when the device switches from one camera to the other. The overall exposure, white balance, and focus position however should be consistent.
    case backTripleCamera
}
