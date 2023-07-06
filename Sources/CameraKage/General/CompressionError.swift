//
//  CompressionError.swift
//  
//
//  Created by Lobont Andrei on 05.07.2023.
//

import Foundation

public enum CompressionError: Error {
    /// Occurs when the given URL can't be converted to an AVAsset.
    case failedToLoadTrackToCompress
    
    /// Failed to write the compressed video.
    case failedToWriteVideo
    
    /// Audio was found but writting it failed.
    case failedToWriteAudio
    
    /// Failed to compress or resize the image.
    case failedToCompressImage
}
