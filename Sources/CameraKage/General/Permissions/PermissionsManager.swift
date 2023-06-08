//
//  PermissionsManager.swift
//  CameraKage
//
//  Created by Lobont Andrei on 23.05.2023.
//

import AVFoundation

final class PermissionsManager: PermissionsManagerProtocol {
    func getAuthorizationStatus(for media: MediaType) -> PermissionStatus {
        switch AVCaptureDevice.authorizationStatus(for: media.avMediaType) {
        case .notDetermined: return .notDetermined
        case .denied: return .denied
        case .authorized: return .authorized
        default: return .notDetermined
        }
    }
    
    func requestAccess(for media: MediaType) async -> Bool {
        let status = getAuthorizationStatus(for: media)
        var isAuthorized = status == .authorized
        if status == .notDetermined {
            isAuthorized = await AVCaptureDevice.requestAccess(for: media.avMediaType)
        }
        return isAuthorized
    }
    
    func requestAccess(for media: MediaType, completion: @escaping((Bool) -> Void)) {
        let status = getAuthorizationStatus(for: media)
        let isAuthorized = status == .authorized
        if status == .notDetermined {
            AVCaptureDevice.requestAccess(for: media.avMediaType) { granted in
                completion(granted)
            }
        } else {
            completion(isAuthorized)
        }
    }
}
