//
//  PermissionsManagerProtocol.swift
//  
//
//  Created by Lobont Andrei on 05.06.2023.
//

import AVFoundation

protocol PermissionsManagerProtocol {
    func getAuthorizationStatus(for media: AVMediaType) -> PermissionStatus
    func requestAccess(for media: AVMediaType) async -> Bool
    func requestAccess(for media: AVMediaType, completion: @escaping((Bool) -> Void))
}
