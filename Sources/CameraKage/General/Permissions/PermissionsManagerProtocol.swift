//
//  PermissionsManagerProtocol.swift
//  
//
//  Created by Lobont Andrei on 05.06.2023.
//

import AVFoundation

protocol PermissionsManagerProtocol {
    func getAuthorizationStatus(for media: MediaType) -> PermissionStatus
    func requestAccess(for media: MediaType) async -> Bool
    func requestAccess(for media: MediaType, completion: @escaping((Bool) -> Void))
}
