//
//  AVAsset+TrackLoading.swift
//  
//
//  Created by Lobont Andrei on 05.07.2023.
//

import AVFoundation

extension AVAsset {
    func getTrack(for mediaTrack: AVMediaType,
                  completion: @escaping((Result<AVAssetTrack?, CompressionError>) -> Void)) {
        loadTracks(withMediaType: mediaTrack) { tracksList, error in
            guard error == nil else {
                completion(.failure(.failedToLoadTrackToCompress))
                return
            }
            guard let tracksList, let firstTrack = tracksList.first else {
                completion(.success(nil))
                return
            }
            completion(.success(firstTrack))
        }
    }
}
