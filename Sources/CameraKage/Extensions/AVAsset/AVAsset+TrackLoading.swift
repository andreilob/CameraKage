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
        if #available(iOS 15.0, *) {
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
        } else {
            DispatchQueue.global().async { [weak self] in
                guard let self else { return }
                guard let firstTrack = self.tracks(withMediaType: mediaTrack).first else {
                    completion(.success(nil))
                    return
                }
                completion(.success(firstTrack))
            }
        }
    }
}
