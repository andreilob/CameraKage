//
//  CompressionAssetsManagerBuilder.swift
//  
//
//  Created by Lobont Andrei on 05.07.2023.
//

import AVFoundation

class CompressionAssetsManagerBuilder {
    private var videoWriter: AVAssetWriter?
    private var videoReader: AVAssetReader?
    private var videoWriterInput: AVAssetWriterInput?
    private var videoReaderOutput: AVAssetReaderTrackOutput?
    private var audioReader: AVAssetReader?
    private var audioWriterInput: AVAssetWriterInput?
    private var audioReaderOutput: AVAssetReaderTrackOutput?
    
    func setVideoWriter(_ videoWriter: AVAssetWriter) {
        self.videoWriter = videoWriter
    }
    
    func setVideoReader(_ videoReader: AVAssetReader) {
        self.videoReader = videoReader
    }
    
    func setVideoWriterInput(_ videoWriterInput: AVAssetWriterInput) {
        self.videoWriterInput = videoWriterInput
    }
    
    func setVideoReaderOutput(_ videoReaderOutput: AVAssetReaderTrackOutput) {
        self.videoReaderOutput = videoReaderOutput
    }
    
    func setAudioReader(_ audioReader: AVAssetReader) {
        self.audioReader = audioReader
    }
    
    func setAudioWriter(_ audioWriter: AVAssetWriterInput) {
        self.audioWriterInput = audioWriter
    }
    
    func setAudioReaderOutput(_ audioReaderOutput: AVAssetReaderTrackOutput) {
        self.audioReaderOutput = audioReaderOutput
    }
    
    func build() throws -> CompressionAssetsManager {
        guard let videoWriter,
              let videoReader,
              let videoWriterInput,
              let videoReaderOutput else {
            throw CompressionError.failedToWriteVideo
        }
        return CompressionAssetsManager(videoWriter: videoWriter,
                                 videoReader: videoReader,
                                 videoWriterInput: videoWriterInput,
                                 videoReaderOutput: videoReaderOutput,
                                 audioReader: audioReader,
                                 audioWriterInput: audioWriterInput,
                                 audioReaderOutput: audioReaderOutput)
    }
}
