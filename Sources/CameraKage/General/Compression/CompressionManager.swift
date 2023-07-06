//
//  CompressionManager.swift
//  
//
//  Created by Lobont Andrei on 04.07.2023.
//

import AVFoundation
import UIKit

protocol CompressionManagerInterface {
    func compressVideo(withURL url: URL,
                       resolution: Resolution,
                       bitrate: BitRate,
                       handler: @escaping (Result<URL, CompressionError>) -> Void)
    func compressImage(withData data: Data,
                       compressionQuality: ImageQuality,
                       resolution: Resolution,
                       completion: @escaping ((Result<Data, CompressionError>) -> Void))
}

final class CompressionManager: CompressionManagerInterface {
    private let videoCompressQueue = DispatchQueue(label: "LA.cameraKage.videoCompressQueue",
                                                   qos: .userInitiated)
    private let videoReadAndWriteQueue = DispatchQueue(label: "LA.cameraKage.videoReadAndWriteQueue",
                                                       qos: .userInitiated)
    private let photoCompressQueue = DispatchQueue(label: "LA.cameraKage.photoCompressQueue",
                                                   qos: .userInitiated,
                                                   attributes: .concurrent)
    
    func compressVideo(withURL url: URL,
                       resolution: Resolution,
                       bitrate: BitRate,
                       handler: @escaping (Result<URL, CompressionError>) -> Void) {
        let videoAsset = AVURLAsset(url: url, options: nil)
        videoAsset.getTrack(for: .video) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let videoTrack):
                guard let videoTrack else { return }
                let compressionAssetsManagerBuilder = CompressionAssetsManagerBuilder()
                let videoWriterSettings = createVideoWriterInputSettings(forVideoTrack: videoTrack,
                                                                         resolution: resolution,
                                                                         bitrate: bitrate)
                let destinationPath = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("compressed.mov")
                try? FileManager.default.removeItem(at: destinationPath)
                
                let videoWriterInput = createWriterInput(with: videoWriterSettings)
                videoWriterInput.transform = videoTrack.preferredTransform
                compressionAssetsManagerBuilder.setVideoWriterInput(videoWriterInput)
                
                guard let videoWriter = try? AVAssetWriter(outputURL: destinationPath, fileType: AVFileType.mov) else {
                    handler(.failure(.failedToWriteVideo))
                    return
                }
                videoWriter.add(videoWriterInput)
                let videoReaderSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange) as AnyObject]
                let videoReaderOutput = AVAssetReaderTrackOutput(track: videoTrack,
                                                                 outputSettings: videoReaderSettings)
                compressionAssetsManagerBuilder.setVideoReaderOutput(videoReaderOutput)
                
                guard let videoReader = try? AVAssetReader(asset: videoAsset) else {
                    handler(.failure(.failedToWriteVideo))
                    return
                }
                videoReader.add(videoReaderOutput)
                compressionAssetsManagerBuilder.setVideoReader(videoReader)
                
                let audioWriterInput = AVAssetWriterInput(mediaType: AVMediaType.audio, outputSettings: nil)
                audioWriterInput.expectsMediaDataInRealTime = false
                videoWriter.add(audioWriterInput)
                compressionAssetsManagerBuilder.setVideoWriter(videoWriter)
                videoAsset.getTrack(for: .audio) { [weak self] result in
                    guard let self else { return }
                    switch result {
                    case .success(let audioTrack):
                        guard let audioTrack else {
                            guard let assetsManager = try? compressionAssetsManagerBuilder.build() else { return }
                            self.startReadingAndWriting(onOutputURL: destinationPath,
                                                        assetsManager: assetsManager,
                                                        handler: { (compressedFileURL) in
                                handler(.success(compressedFileURL))
                            })
                            return
                        }
                        
                        let audioReaderOutput = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: nil)
                        compressionAssetsManagerBuilder.setAudioReaderOutput(audioReaderOutput)
                        compressionAssetsManagerBuilder.setAudioWriter(audioWriterInput)
                        
                        guard let audioReader = try? AVAssetReader(asset: videoAsset) else {
                            handler(.failure(.failedToWriteAudio))
                            return
                        }
                        audioReader.add(audioReaderOutput)
                        compressionAssetsManagerBuilder.setAudioReader(audioReader)
                        guard let videoAssetManager = try? compressionAssetsManagerBuilder.build() else { return }
                        self.startReadingAndWriting(onOutputURL: destinationPath,
                                                    assetsManager: videoAssetManager,
                                                    handler: { (compressedFileURL) in
                            handler(.success(compressedFileURL))
                        })
                    case .failure(let error):
                        handler(.failure(error))
                    }
                }
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
    
    func compressImage(withData data: Data,
                       compressionQuality: ImageQuality,
                       resolution: Resolution,
                       completion: @escaping ((Result<Data, CompressionError>) -> Void)) {
        photoCompressQueue.async {
            let image = UIImage(data: data)
            let resizedImage = image?.resized(to: CGSize(width: resolution.width, height: resolution.height))
            guard let data = resizedImage?.jpegData(compressionQuality: compressionQuality.rawValue) else {
                DispatchQueue.main.async {
                    completion(.failure(.failedToCompressImage))
                }
                return
            }
            DispatchQueue.main.async {
                completion(.success(data))
            }
        }
    }
    
    private func startReadingAndWriting(onOutputURL outputURL: URL,
                                        assetsManager: CompressionAssetsManager,
                                        handler: @escaping ((URL) -> Void)) {
        assetsManager.videoWriter.startWriting()
        assetsManager.videoReader.startReading()
        assetsManager.videoWriter.startSession(atSourceTime: CMTime.zero)
        assetsManager.videoWriterInput.requestMediaDataWhenReady(on: videoCompressQueue,
                                                                 using: { [weak self] () -> Void in
            guard let self else { return }
            while assetsManager.videoWriterInput.isReadyForMoreMediaData {
                let sampleBuffer: CMSampleBuffer? = assetsManager.videoReaderOutput.copyNextSampleBuffer()
                if assetsManager.videoReader.status == .reading && sampleBuffer != nil {
                    if let sBuffer = sampleBuffer {
                        assetsManager.videoWriterInput.append(sBuffer)
                    }
                } else {
                    assetsManager.videoWriterInput.markAsFinished()
                    if assetsManager.videoReader.status == .completed, assetsManager.audioReader != nil {
                        assetsManager.audioReader?.startReading()
                        assetsManager.videoWriter.startSession(atSourceTime: CMTime.zero)
                        assetsManager.audioWriterInput?.requestMediaDataWhenReady(on: self.videoReadAndWriteQueue,
                                                                                  using: {() -> Void in
                            while assetsManager.audioWriterInput?.isReadyForMoreMediaData ?? false {
                                let sampleBuffer: CMSampleBuffer? = assetsManager.audioReaderOutput?.copyNextSampleBuffer()
                                if assetsManager.audioReader?.status == .reading && sampleBuffer != nil {
                                    if let sBuffer = sampleBuffer {
                                        assetsManager.audioWriterInput?.append(sBuffer)
                                    }
                                } else {
                                    assetsManager.audioWriterInput?.markAsFinished()
                                    if assetsManager.audioReader?.status == .completed {
                                        assetsManager.videoWriter.finishWriting(completionHandler: { () -> Void in
                                            handler(outputURL)
                                        })
                                    }
                                }
                            }
                        })
                    } else if assetsManager.videoReader.status == .completed {
                        assetsManager.videoWriter.finishWriting(completionHandler: { () -> Void in
                            handler(outputURL)
                        })
                    }
                }
            }
        })
    }
    
    private func createWriterInput(with settings: [String: AnyObject]?) -> AVAssetWriterInput {
        let videoWriterInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: settings)
        videoWriterInput.expectsMediaDataInRealTime = true
        return videoWriterInput
    }
    
    private func createVideoWriterInputSettings(forVideoTrack videoTrack: AVAssetTrack,
                                                resolution: Resolution,
                                                bitrate: BitRate) -> [String: AnyObject]? {
        [
            AVVideoCodecKey: AVVideoCodecType.hevc as AnyObject,
            AVVideoCompressionPropertiesKey: [AVVideoAverageBitRateKey: Int(bitrate.rawValue)] as AnyObject,
            AVVideoWidthKey: videoTrack.naturalSize.width < resolution.width ? videoTrack.naturalSize.width as AnyObject : resolution.width as AnyObject,
            AVVideoHeightKey: videoTrack.naturalSize.height < resolution.height ? videoTrack.naturalSize.height as AnyObject : resolution.height as AnyObject
        ]
    }
}
