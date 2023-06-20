//
//  VideoCameraViewTests.swift
//  
//
//  Created by Lobont Andrei on 19.06.2023.
//

import XCTest
@testable import CameraKage

final class VideoCameraViewTest: XCTestCase {
    func test_startAndStopRecording() {
        let sessionMock = makeSessionMock()
        let options = CameraComponentParsedOptions(nil)
        let videoInputMock = makeVideoInputMock(options: options)
        let videoLayerMock = makeVideoLayerMock()
        let movieCapturerMock = makeMovieOutputMock()
        let camera = makeVideoCamera(session: sessionMock,
                                     videoInput: videoInputMock,
                                     videoLayer: videoLayerMock,
                                     movieCapturer: movieCapturerMock,
                                     options: options)
        let sessionQueue = DispatchQueue(label: "testSessionQueue")
        let sut = makeSUT(camera: camera, sessionQueue: sessionQueue)
        
        XCTAssertFalse(movieCapturerMock.isRecording, "Recording not yet started.")
        
        sut.startVideoRecording()
        sessionQueue.sync {}
        XCTAssertTrue(movieCapturerMock.isRecording)
        
        sut.stopVideoRecording()
        sessionQueue.sync {}
        XCTAssertFalse(movieCapturerMock.isRecording)
    }
    
    func test_videoDevice_configureFlashMode() {
        let sessionMock = makeSessionMock()
        let options = CameraComponentParsedOptions(nil)
        let videoInputMock = makeVideoInputMock(options: options)
        let videoLayerMock = makeVideoLayerMock()
        let movieCapturerMock = makeMovieOutputMock()
        let camera = makeVideoCamera(session: sessionMock,
                                     videoInput: videoInputMock,
                                     videoLayer: videoLayerMock,
                                     movieCapturer: movieCapturerMock,
                                     options: options)
        let sessionQueue = DispatchQueue(label: "testSessionQueue")
        let sut = makeSUT(camera: camera, sessionQueue: sessionQueue)
        
        XCTAssertNil(videoInputMock.flashMode, "Recording not yet started.")
        
        sut.startVideoRecording(flashOption: .on)
        sessionQueue.sync {}
        XCTAssertEqual(videoInputMock.flashMode, .on)
        
        sut.stopVideoRecording()
        sessionQueue.sync {}
        XCTAssertEqual(videoInputMock.flashMode, .off)
    }
    
    func test_videoDevice_configureFlashMode_frontCamera() {
        let sessionMock = makeSessionMock()
        let options = CameraComponentParsedOptions([.cameraDevice(.frontCamera)])
        let videoInputMock = makeVideoInputMock(options: options)
        let videoLayerMock = makeVideoLayerMock()
        let movieCapturerMock = makeMovieOutputMock()
        let camera = makeVideoCamera(session: sessionMock,
                                     videoInput: videoInputMock,
                                     videoLayer: videoLayerMock,
                                     movieCapturer: movieCapturerMock,
                                     options: options)
        let sessionQueue = DispatchQueue(label: "testSessionQueue")
        let sut = makeSUT(camera: camera, sessionQueue: sessionQueue)
        
        XCTAssertNil(videoInputMock.flashMode, "Recording not yet started.")
        
        sut.startVideoRecording(flashOption: .on)
        sessionQueue.sync {}
        
        XCTAssertNil(videoInputMock.flashMode, "Front camera dosen't support flash mode.")
    }
}

extension VideoCameraViewTest {
    private func makeSUT(camera: VideoCamera, sessionQueue: DispatchQueue)-> VideoCameraView {
        let sut = VideoCameraView(videoCamera: camera, sessionQueue: sessionQueue)
        trackMemoryLeaks(sut)
        return sut
    }
    
    private func makeVideoCamera(session: Session,
                                 videoInput: VideoInput,
                                 videoLayer: VideoLayer,
                                 movieCapturer: MovieCapturer,
                                 options: CameraComponentParsedOptions) -> VideoCamera {
        let mock = VideoCamera(session: session,
                               videoInput: videoInput,
                               videoLayer: videoLayer,
                               movieCapturer: movieCapturer,
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
    
    private func makeMovieOutputMock() -> MovieOutputMock {
        let mock = MovieOutputMock()
        trackMemoryLeaks(mock)
        return mock
    }
}
