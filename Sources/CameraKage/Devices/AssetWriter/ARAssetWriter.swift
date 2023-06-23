//
//  ARAssetWriter.swift
//  
//
//  Created by Lobont Andrei on 20.06.2023.
//

import AVFoundation
import CoreVideo
import UIKit

private struct RecordSettings {
    static var fileUrl: URL = .makeTempUrl(for: .video)
    static let fileType: AVFileType = .mov
    
    static let videoFps: Int = 60
    static let videoCodec: AVVideoCodecType = .h264
    static let maxVideoSize: CGSize = CGSize(width: 1080, height: 1920)
    
    static let audioNumberOfChannels: Int = 1
    static let audioSampleRate: Int = 44100
    static let audioEncoderBitRate: Int = 64000
}

class ARAssetWriter: AssetWriterInterface {
    private var assetWriter: AVAssetWriter?
    private var writerVideoInput: AVAssetWriterInput?
    private var pixelBufferAdapter: AVAssetWriterInputPixelBufferAdaptor?
    private var writerAudioInput: AVAssetWriterInput?
    private var displayTimer: CADisplayLink?
    private var recordShouldStartSessionOnFirstFrame = false
    private var recordVideoSize: CGSize = .zero
    private var recordQueue = DispatchQueue(label: "LA.cameraKage.assetWriter.recorderQueue")
    private let arView: ARPreviewView
    private lazy var videoSettings: [String: Any] = [AVVideoCodecKey: RecordSettings.videoCodec,
                                                     AVVideoWidthKey: recordVideoSize.width,
                                                    AVVideoHeightKey: recordVideoSize.height]
    private lazy var audioSettings: [String: Any] = [AVFormatIDKey: kAudioFormatMPEG4AAC,
                                             AVNumberOfChannelsKey: RecordSettings.audioNumberOfChannels,
                                                   AVSampleRateKey: RecordSettings.audioSampleRate,
                                               AVEncoderBitRateKey: RecordSettings.audioEncoderBitRate]
    
    var isRecording: Bool { assetWriter?.status == .writing }
    
    weak var delegate: ARAssetWriterDelegate?
    
    init(arView: ARPreviewView) {
        self.arView = arView
        recordVideoSize = arView.bounds.size.scaled(by: UIScreen.main.scale).aspectFit(to: RecordSettings.maxVideoSize)
    }
    
    func capturePhoto() {
        let displayTimer = CADisplayLink(target: self, selector: #selector(captureFrame))
        displayTimer.add(to: .main, forMode: .common)
        self.displayTimer = displayTimer
    }
    
    func startVideoRecording() {
        recordQueue.async { [weak self] in
            guard let self, !self.isRecording else { return }
            try? FileManager.default.removeItem(at: RecordSettings.fileUrl)
            guard let assetWriter = try? AVAssetWriter(url: RecordSettings.fileUrl,
                                                       fileType: RecordSettings.fileType) else {
                self.delegate?.assetWriter(didEncounterError: .failedToRecordARVideo)
                return
            }
            self.assetWriter = assetWriter
            
            self.createVideoAssetWriterInput(assetWriter: assetWriter)
            guard let writerVideoInput = self.writerVideoInput else { return }
            self.createPixelBufferAdapter(writerVideoInput: writerVideoInput)
            self.createAudioAssetWriterInput(assetWriter: assetWriter)
            
            self.recordShouldStartSessionOnFirstFrame = true
            guard assetWriter.startWriting() else {
                self.delegate?.assetWriter(didEncounterError: .failedToRecordARVideo)
                return
            }
            self.delegate?.assetWriter(didBeginRecordingVideoAtURL: RecordSettings.fileUrl)
            self.createVideoDisplayLink()
        }
    }
    
    func stopVideoRecording() {
        recordQueue.async { [weak self] in
            guard let self, self.isRecording else { return }
            self.assetWriter?.finishWriting { [weak self] in
                guard let self else { return }
                self.delegate?.assetWriter(didRecordVideoAtURL: RecordSettings.fileUrl)
            }
            self.displayTimer?.invalidate()
            self.assetWriter = nil
            self.writerAudioInput = nil
            self.pixelBufferAdapter = nil
            self.writerVideoInput = nil
            self.displayTimer = nil
        }
    }
    
    func appendAudioBuffer(_ buffer: CMSampleBuffer) {
        guard !recordShouldStartSessionOnFirstFrame else { return }
        recordQueue.async { [weak self] in
            guard let self, self.assetWriter?.status == .writing else { return }
            guard self.writerAudioInput?.isReadyForMoreMediaData == true else {
                self.delegate?.assetWriter(didEncounterError: .failedToRecordAudioBuffer)
                return
            }
            self.writerAudioInput?.append(buffer)
        }
    }
    
    private func createVideoDisplayLink() {
        let displayTimer = CADisplayLink(target: self, selector: #selector(recordFrame))
        displayTimer.preferredFramesPerSecond = RecordSettings.videoFps
        displayTimer.add(to: .main, forMode: .common)
        self.displayTimer = displayTimer
    }
    
    private func createVideoAssetWriterInput(assetWriter: AVAssetWriter) {
        let writerVideoInput = AVAssetWriterInput(mediaType: .video,
                                                  outputSettings: self.videoSettings)
        writerVideoInput.expectsMediaDataInRealTime = true
        guard assetWriter.canAdd(writerVideoInput) else {
            self.delegate?.assetWriter(didEncounterError: .failedToRecordARVideo)
            return
        }
        assetWriter.add(writerVideoInput)
        self.writerVideoInput = writerVideoInput
    }
    
    private func createAudioAssetWriterInput(assetWriter: AVAssetWriter) {
        let writerAudioInput = AVAssetWriterInput(mediaType: .audio,
                                                  outputSettings: self.audioSettings)
        writerAudioInput.expectsMediaDataInRealTime = true
        guard assetWriter.canAdd(writerAudioInput) else {
            self.delegate?.assetWriter(didEncounterError: .failedToRecordARVideo)
            return
        }
        assetWriter.add(writerAudioInput)
        self.writerAudioInput = writerAudioInput
    }
    
    private func createPixelBufferAdapter(writerVideoInput: AVAssetWriterInput) {
        let pixelBufferAttributes = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32ARGB)]
        pixelBufferAdapter = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: writerVideoInput,
                                                                      sourcePixelBufferAttributes: pixelBufferAttributes)
    }
    
    @objc private func recordFrame() {
        let frameTime = CACurrentMediaTime()
        if recordShouldStartSessionOnFirstFrame {
            assetWriter?.startSession(atSourceTime: frameTime.asCMTime)
            recordShouldStartSessionOnFirstFrame = false
        }
        let image = arView.renderer.snapshot(atTime: frameTime,
                                             with: recordVideoSize,
                                             antialiasingMode: .none)
        recordQueue.async { [weak self] in
            guard let self,
                  self.assetWriter?.status == .writing,
                  self.writerVideoInput?.isReadyForMoreMediaData == true,
                  let pixelBuffer = image.pixelBuffer() else { return }
            self.pixelBufferAdapter?.append(pixelBuffer, withPresentationTime: frameTime.asCMTime)
        }
    }
    
    @objc private func captureFrame() {
        let frameTime = CACurrentMediaTime()
        let image = arView.renderer.snapshot(atTime: frameTime,
                                             with: recordVideoSize,
                                             antialiasingMode: .none)
        if let data = image.jpegData(compressionQuality: 1.0) {
            delegate?.assetWriter(didCapturePhotoWithData: data)
        }
        displayTimer?.invalidate()
        displayTimer = nil
    }
}
