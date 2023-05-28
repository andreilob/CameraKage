//
//  SessionInterruptionReason.swift
//  CameraKage
//
//  Created by Lobont Andrei on 24.05.2023.
//

import Foundation

public enum SessionInterruptionReason {
    /// An unhandled case appeared.
    case unknown

    /// An interruption caused by the app being sent to the background while using a camera. Camera usage is prohibited while in the background. Provided you don't explicitly call [session stopRunning], your -startRunning request is preserved, and when your app comes back to foreground, you receive AVCaptureSessionInterruptionEndedNotification and your session starts running.
    case videoDeviceNotAvailableInBackground

    /// An interruption caused by the audio hardware temporarily being made unavailable, for instance, for a phone call, or alarm.
    case audioDeviceInUseByAnotherClient

    /// An interruption caused by the video device temporarily being made unavailable, for instance, when stolen away by another AVCaptureSession.
    case videoDeviceInUseByAnotherClient

    /// An interruption caused when the app is running in a multi-app layout, causing resource contention and degraded recording quality of service. Given your present AVCaptureSession configuration, the session may only be run if your app occupies the full screen.
    case videoDeviceNotAvailableWithMultipleForegroundApps

    /// An interruption caused by the video device temporarily being made unavailable due to system pressure, such as thermal duress.
    case videoDeviceNotAvailableDueToSystemPressure
}
