//
//  URL+TemporaryURL.swift
//  CameraKage
//
//  Created by Lobont Andrei on 22.05.2023.
//

import Foundation

extension URL {
    static func makeTempUrl(for type: OutputType) -> URL {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        switch type {
        case .photo: return url.appendingPathExtension("jpg")
        case .video: return url.appendingPathExtension("mov")
        }
    }
}
