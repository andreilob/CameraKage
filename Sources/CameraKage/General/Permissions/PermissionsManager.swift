//
//  PermissionsManager.swift
//  CameraKage
//
//  Created by Lobont Andrei on 23.05.2023.
//

import AVFoundation

final class PermissionsManager: PermissionsManagerProtocol {
    func getAuthorizationStatus(for media: AVMediaType) -> PermissionStatus {
        switch AVCaptureDevice.authorizationStatus(for: media) {
        case .notDetermined: return .notDetermined
        case .denied: return .denied
        case .authorized: return .authorized
        default: return .denied
        }
    }
    
    func requestAccess(for media: AVMediaType) async -> Bool {
        let status = getAuthorizationStatus(for: media)
        var isAuthorized = status == .authorized
        if status == .notDetermined {
            isAuthorized = await AVCaptureDevice.requestAccess(for: media)
        }
        return isAuthorized
    }
    
    func requestAccess(for media: AVMediaType, completion: @escaping((Bool) -> Void)) {
        let status = getAuthorizationStatus(for: media)
        let isAuthorized = status == .authorized
        if status == .notDetermined {
            AVCaptureDevice.requestAccess(for: media) { granted in
                completion(granted)
            }
        } else {
            completion(isAuthorized)
        }
    }
}
