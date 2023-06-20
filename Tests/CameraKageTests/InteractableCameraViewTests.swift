//
//  InteractableCameraViewTests.swift
//  
//
//  Created by Lobont Andrei on 14.06.2023.
//

import XCTest
@testable import CameraKage

final class InteractableCameraViewTests: XCTestCase {
    func test_flipCamera() {
        let sessionMock = makeSessionMock()
        let options = CameraComponentParsedOptions(nil)
        let videoInputMock = makeVideoInputMock(options: options)
        let videoLayerMock = makeVideoLayerMock()
        let camera = makeInteractableCamera(session: sessionMock,
                                            videoInput: videoInputMock,
                                            videoLayer: videoLayerMock,
                                            options: options)
        let sessionQueue = DispatchQueue(label: "testSessionQueue")
        let sut = makeSUT(interactableCamera: camera, sessionQueue: sessionQueue)
        
        XCTAssertEqual(videoInputMock.currentCamera, options.cameraDevice, "Starting with original camera.")
        
        sut.flipCamera()
        sessionQueue.sync {}
        
        XCTAssertEqual(videoInputMock.currentCamera, options.flipCameraDevice)
    }
    
    func test_focusCamera() {
        let sessionMock = makeSessionMock()
        let options = CameraComponentParsedOptions(nil)
        let videoInputMock = makeVideoInputMock(options: options)
        let videoLayerMock = makeVideoLayerMock()
        let camera = makeInteractableCamera(session: sessionMock,
                                            videoInput: videoInputMock,
                                            videoLayer: videoLayerMock,
                                            options: options)
        let sessionQueue = DispatchQueue(label: "testSessionQueue")
        let sut = makeSUT(interactableCamera: camera, sessionQueue: sessionQueue)
        
        XCTAssertNil(videoInputMock.focusMode, "No focus set yet.")
        XCTAssertNil(videoInputMock.exposureMode, "No focus set yet.")
        XCTAssertEqual(videoInputMock.focusPoint, .zero, "No focus set yet.")
        
        let focusPoint = CGPoint(x: 100, y: 100)
        sut.focus(with: .locked,
                  exposureMode: .continuousAutoExposure,
                  at: focusPoint,
                  monitorSubjectAreaChange: true)
        sessionQueue.sync {}
        
        let convertedFocusPoint = videoLayerMock.captureDevicePointConverted(fromLayerPoint: focusPoint)
        XCTAssertEqual(videoInputMock.focusPoint, convertedFocusPoint)
        XCTAssertEqual(videoInputMock.focusMode, .locked)
        XCTAssertEqual(videoInputMock.exposureMode, .continuousAutoExposure)
    }
}

extension InteractableCameraViewTests {
    private func makeSUT(interactableCamera: InteractableCameraInterface,
                         sessionQueue: DispatchQueue) -> InteractableCameraView {
        let sut = InteractableCameraView(interactableCamera: interactableCamera,
                                         sessionQueue: sessionQueue)
        trackMemoryLeaks(sut)
        return sut
    }
    
    private func makeInteractableCamera(session: Session,
                                        videoInput: VideoInput,
                                        videoLayer: VideoLayer,
                                        options: CameraComponentParsedOptions) -> InteractableCamera {
        let mock = InteractableCamera(session: session,
                                      videoInput: videoInput,
                                      videoLayer: videoLayer,
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
}
