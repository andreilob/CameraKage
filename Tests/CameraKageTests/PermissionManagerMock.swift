//
//  File.swift
//  
//
//  Created by Lobont Andrei on 29.05.2023.
//

import Foundation
@testable import CameraKage

final class PermissionManagerMock: PermissionsManagerProtocol {
    private var authorizedVideo: Bool?
    private var authorizedAudio: Bool?
    
    func getAuthorizationStatus(for media: MediaType) -> PermissionStatus {
        switch media {
        case .audio:
            guard let authorizedAudio else { return .notDetermined }
            return authorizedAudio ? .authorized : .denied
        case .video:
            guard let authorizedVideo else { return .notDetermined }
            return authorizedVideo ? .authorized : .denied
        }
    }
    
    func requestAccess(for media: MediaType) async -> Bool {
        switch media {
        case .audio:
            authorizedAudio = true
            return authorizedAudio ?? true
        case .video:
            authorizedVideo = true
            return authorizedVideo ?? true
        }
    }
    
    func requestAccess(for media: MediaType, completion: @escaping ((Bool) -> Void)) {
        switch media {
        case .audio:
            authorizedAudio = true
            completion(authorizedAudio ?? true)
        case .video:
            authorizedVideo = true
            completion(authorizedVideo ?? true)
        }
    }
}
