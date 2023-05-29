//
//  File.swift
//  
//
//  Created by Lobont Andrei on 29.05.2023.
//

import AVFoundation
@testable import CameraKage

class PermissionManagerMock: PermissionsManagerProtocol {
    private var authorizedVideo = false
    private var authorizedAudio = false
    
    func getAuthorizationStatus(for media: AVMediaType) -> PermissionStatus {
        switch media {
        case .audio: return authorizedAudio ? .authorized : .denied
        case .video: return authorizedVideo ? .authorized : .denied
        default: return .notDetermined // not using other media type yet
        }
    }
    
    func requestAccess(for media: AVMediaType) async -> Bool {
        switch media {
        case .audio:
            authorizedAudio = true
            return authorizedAudio
        case .video:
            authorizedVideo = true
            return authorizedVideo
        default:
            return false // not using other media type yet
        }
    }
    
    func requestAccess(for media: AVMediaType, completion: @escaping ((Bool) -> Void)) {
        switch media {
        case .audio:
            authorizedAudio = true
            completion(authorizedAudio)
        case .video:
            authorizedVideo = true
            completion(authorizedVideo)
        default:
            break // not using other media type yet
        }
    }
}
