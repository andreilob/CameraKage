//
//  MetadataCameraViewTests.swift
//  
//
//  Created by Lobont Andrei on 20.06.2023.
//

import XCTest
@testable import CameraKage

final class MetadataCameraViewTests: XCTestCase {
    func test_videoDevice_configureFlashMode() {
        let sessionMock = makeSessionMock()
        let options = CameraComponentParsedOptions(nil)
        let videoInputMock = makeVideoInputMock(options: options)
        let videoLayerMock = makeVideoLayerMock()
        let metadataCapturerMock = makeMetadataOutputMock()
        let camera = makeMetadataCamera(session: sessionMock,
                                        videoInput: videoInputMock,
                                        videoLayer: videoLayerMock,
                                        metadataCapturer: metadataCapturerMock,
                                        options: options)
        let sessionQueue = DispatchQueue(label: "testSessionQueue")
        let sut = makeSUT(camera: camera, sessionQueue: sessionQueue)
        
        XCTAssertNil(videoInputMock.flashMode, "Recording not yet started.")
        
        sut.configureTorchSetting(torchOption: .on)
        sessionQueue.sync {}
        XCTAssertEqual(videoInputMock.flashMode, .on)
        
        sut.configureTorchSetting(torchOption: .off)
        sessionQueue.sync {}
        XCTAssertEqual(videoInputMock.flashMode, .off)
    }
    
    func test_videoDevice_configureFlashMode_frontCamera() {
        let sessionMock = makeSessionMock()
        let options = CameraComponentParsedOptions([.cameraDevice(.frontCamera)])
        let videoInputMock = makeVideoInputMock(options: options)
        let videoLayerMock = makeVideoLayerMock()
        let metadataCapturerMock = makeMetadataOutputMock()
        let camera = makeMetadataCamera(session: sessionMock,
                                        videoInput: videoInputMock,
                                        videoLayer: videoLayerMock,
                                        metadataCapturer: metadataCapturerMock,
                                        options: options)
        let sessionQueue = DispatchQueue(label: "testSessionQueue")
        let sut = makeSUT(camera: camera, sessionQueue: sessionQueue)
        
        XCTAssertNil(videoInputMock.flashMode, "Recording not yet started.")
        
        sut.configureTorchSetting(torchOption: .on)
        sessionQueue.sync {}
        
        XCTAssertNil(videoInputMock.flashMode, "Front camera dosen't support flash mode.")
    }
}

extension MetadataCameraViewTests {
    private func makeSUT(camera: MetadataCamera, sessionQueue: DispatchQueue)-> MetadataCameraView {
        let sut = MetadataCameraView(metadataCamera: camera, sessionQueue: sessionQueue)
        trackMemoryLeaks(sut)
        return sut
    }
    
    private func makeMetadataCamera(session: Session,
                                    videoInput: VideoInput,
                                    videoLayer: VideoLayer,
                                    metadataCapturer: MetadataCapturer,
                                    options: CameraComponentParsedOptions) -> MetadataCamera {
        let mock = MetadataCamera(session: session,
                                  videoInput: videoInput,
                                  videoLayer: videoLayer,
                                  metadataCapturer: metadataCapturer,
                                  options: options)
        trackMemoryLeaks(mock)
        return mock
    }
    
    private func makeSessionMock() -> CaptureSessionMock {
        let mock = CaptureSessionMock()
        trackMemoryLeaks(mock)
        return mock
    }
    
    private func makeVideoInputMock(options: CameraComponentParsedOptions) -> VideoInputMock {
        let mock = VideoInputMock(options: options)
        trackMemoryLeaks(mock)
        return mock
    }
    
    private func makeVideoLayerMock() -> VideoLayerMock {
        let mock = VideoLayerMock()
        trackMemoryLeaks(mock)
        return mock
    }
    
    private func makeMetadataOutputMock() -> MetadataOutputMock {
        let mock = MetadataOutputMock()
        trackMemoryLeaks(mock)
        return mock
    }
}
