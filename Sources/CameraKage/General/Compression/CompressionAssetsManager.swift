//
//  CompressionAssetsManager.swift
//  
//
//  Created by Lobont Andrei on 04.07.2023.
//

import AVFoundation

struct CompressionAssetsManager {
    var videoWriter: AVAssetWriter
    var videoReader: AVAssetReader
    var videoWriterInput: AVAssetWriterInput
    var videoReaderOutput: AVAssetReaderTrackOutput
    var audioReader: AVAssetReader?
    var audioWriterInput: AVAssetWriterInput?
    var audioReaderOutput: AVAssetReaderTrackOutput?
    
    init(videoWriter: AVAssetWriter,
         videoReader: AVAssetReader,
         videoWriterInput: AVAssetWriterInput,
         videoReaderOutput: AVAssetReaderTrackOutput,
         audioReader: AVAssetReader?,
         audioWriterInput: AVAssetWriterInput?,
         audioReaderOutput: AVAssetReaderTrackOutput?) {
        self.videoWriter = videoWriter
        self.videoReader = videoReader
        self.videoWriterInput = videoWriterInput
        self.videoReaderOutput = videoReaderOutput
        self.audioReader = audioReader
        self.audioWriterInput = audioWriterInput
        self.audioReaderOutput = audioReaderOutput
    }
}
