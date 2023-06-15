//
//  BaseCameraViewTests.swift
//  
//
//  Created by Lobont Andrei on 14.06.2023.
//

import XCTest
@testable import CameraKage

final class BaseCameraViewTests: XCTestCase {
    func test_session_startAndStop_addAndRemoveObservers() {
        let session = makeSessionMock()
        let options = CameraComponentParsedOptions(nil)
        let videoInput = makeVideoInputMock(options: options)
        let videoLayer = makeVideoLayerMock()
        let delegatesManager = makeDelegatesManagerMock()
        let baseCamera = makeBaseCameraMock(session: session,
                                            videoInput: videoInput,
                                            videoLayer: videoLayer,
                                            options: options)
        let sessionQueue = DispatchQueue(label: "testSessionQueue")
        let sut = makeSUT(baseCamera: baseCamera, delegatesManager: delegatesManager, sessionQueue: sessionQueue)
        
        XCTAssertFalse(sut.isSessionRunning, "Session wasn't yet started")
        XCTAssertFalse(session.isObservingSession, "Session not started, observers shouldn't be yet added.")
        
        sut.startCamera()
        sessionQueue.sync {}
        XCTAssertTrue(sut.isSessionRunning)
        XCTAssertTrue(session.isObservingSession)
        
        sut.stopCamera()
        sessionQueue.sync {}
        XCTAssertFalse(sut.isSessionRunning)
        XCTAssertFalse(session.isObservingSession)
    }
    
    func test_session_setDelegate() {
        let session = makeSessionMock()
        let options = CameraComponentParsedOptions(nil)
        let videoInput = makeVideoInputMock(options: options)
        let videoLayer = makeVideoLayerMock()
        let delegatesManager = makeDelegatesManagerMock()
        let baseCamera = makeBaseCameraMock(session: session,
                                            videoInput: videoInput,
                                            videoLayer: videoLayer,
                                            options: options)
        let sessionQueue = DispatchQueue(label: "testSessionQueue")
        XCTAssertNil(session.delegate, "No delegate was set yet.")
        let sut = makeSUT(baseCamera: baseCamera, delegatesManager: delegatesManager, sessionQueue: sessionQueue)
        
        XCTAssertNotNil(session.delegate)
        XCTAssert(session.delegate === sut)
    }
    
    func test_videoInput_flipCamera() {
        let session = makeSessionMock()
        let options = CameraComponentParsedOptions([.cameraDevice(.backTripleCamera),
                                                    .flipCameraDevice(.frontCamera)])
        let videoInput = makeVideoInputMock(options: options)
        let videoLayer = makeVideoLayerMock()
        let delegatesManager = makeDelegatesManagerMock()
        let baseCamera = makeBaseCameraMock(session: session,
                                            videoInput: videoInput,
                                            videoLayer: videoLayer,
                                            options: options)
        let sessionQueue = DispatchQueue(label: "testSessionQueue")
        let sut = makeSUT(baseCamera: baseCamera, delegatesManager: delegatesManager, sessionQueue: sessionQueue)
        
        XCTAssertEqual(videoInput.currentCamera, options.cameraDevice, "Camera should start with the cameraDevice from the options object.")
        
        sut.flipCamera()
        sessionQueue.sync {}
        XCTAssertEqual(videoInput.currentCamera, options.flipCameraDevice)
        
        sut.flipCamera()
        sessionQueue.sync {}
        XCTAssertEqual(videoInput.currentCamera, options.cameraDevice)
    }
    
    func test_videoInput_focus_videoLayer_convertedFocusPoint() {
        let session = makeSessionMock()
        let options = CameraComponentParsedOptions(nil)
        let videoInput = makeVideoInputMock(options: options)
        let videoLayer = makeVideoLayerMock()
        let delegatesManager = makeDelegatesManagerMock()
        let baseCamera = makeBaseCameraMock(session: session,
                                            videoInput: videoInput,
                                            videoLayer: videoLayer,
                                            options: options)
        let sessionQueue = DispatchQueue(label: "testSessionQueue")
        let sut = makeSUT(baseCamera: baseCamera, delegatesManager: delegatesManager, sessionQueue: sessionQueue)
        
        XCTAssertEqual(videoInput.focusPoint, .zero, "Camera wasn't focused yet.")
        
        let focusPoint = CGPoint(x: 100, y: 100)
        sut.focus(with: .locked,
                  exposureMode: .continuousAutoExposure,
                  at: focusPoint,
                  monitorSubjectAreaChange: true)
        sessionQueue.sync {}
        
        let convertedFocusPoint = videoLayer.captureDevicePointConverted(fromLayerPoint: focusPoint)
        XCTAssertEqual(videoInput.focusPoint, convertedFocusPoint)
        XCTAssertEqual(videoInput.focusMode, .locked)
        XCTAssertEqual(videoInput.exposureMode, .continuousAutoExposure)
    }
    
    func test_delegatesManager_registerAndUnregisterDelegate() {
        let session = makeSessionMock()
        let options = CameraComponentParsedOptions(nil)
        let videoInput = makeVideoInputMock(options: options)
        let videoLayer = makeVideoLayerMock()
        let delegatesManager = makeDelegatesManagerMock()
        let delegateStub = makeBaseCameraDelegateStub()
        let baseCamera = makeBaseCameraMock(session: session,
                                            videoInput: videoInput,
                                            videoLayer: videoLayer,
                                            options: options)
        let sessionQueue = DispatchQueue(label: "testSessionQueue")
        let sut = makeSUT(baseCamera: baseCamera, delegatesManager: delegatesManager, sessionQueue: sessionQueue)
        
        XCTAssertEqual(sut.delegatesManager.delegates.count, 0, "No delegates added yet.")
        
        sut.registerDelegate(delegateStub)
        XCTAssertEqual(sut.delegatesManager.delegates.count, 1)
        
        sut.unregisterDelegate(delegateStub)
        XCTAssertEqual(sut.delegatesManager.delegates.count, 0)
    }
    
    func test_delegatesManager_invokeDelegates() {
        let session = makeSessionMock()
        let options = CameraComponentParsedOptions(nil)
        let videoInput = makeVideoInputMock(options: options)
        let videoLayer = makeVideoLayerMock()
        let delegatesManager = makeDelegatesManagerMock()
        let delegateStub = makeBaseCameraDelegateStub()
        let baseCamera = makeBaseCameraMock(session: session,
                                            videoInput: videoInput,
                                            videoLayer: videoLayer,
                                            options: options)
        let sessionQueue = DispatchQueue(label: "testSessionQueue")
        let sut = makeSUT(baseCamera: baseCamera, delegatesManager: delegatesManager, sessionQueue: sessionQueue)
        
        XCTAssertFalse(delegateStub.invoked)
        
        sut.registerDelegate(delegateStub)
        
        delegatesManager.invokeDelegates { delegate in
            guard let delegate = delegate as? BaseCameraDelegateStub else {
                XCTFail("Failed to cast delegate")
                return
            }
            delegate.invoked = true
        }
        XCTAssertTrue(delegateStub.invoked)
    }
}

extension BaseCameraViewTests {
    private func makeSUT(baseCamera: BaseCameraInterface,
                         delegatesManager: DelegatesManagerProtocol,
                         sessionQueue: DispatchQueue) -> BaseCameraView {
        let sut = BaseCameraView(baseCamera: baseCamera, delegatesManager: delegatesManager, sessionQueue: sessionQueue)
        trackMemoryLeaks(sut)
        return sut
    }
    
    private func makeBaseCameraMock(session: Session,
                                    videoInput: VideoInput,
                                    videoLayer: VideoLayer,
                                    options: CameraComponentParsedOptions) -> BaseCameraMock {
        let mock = BaseCameraMock(session: session,
                                  videoInput: videoInput,
                                  videoLayer: videoLayer,
                                  options: options)
        trackMemoryLeaks(mock)
        return mock
    }
    
    private func makeSessionMock() -> CaptureSessionMock {
        CaptureSessionMock()
    }
    
    private func makeVideoInputMock(options: CameraComponentParsedOptions) -> VideoInputMock {
        VideoInputMock(options: options)
    }
    
    private func makeVideoLayerMock() -> VideoLayerMock {
        VideoLayerMock()
    }
    
    private func makeDelegatesManagerMock() -> DelegatesManagerMock {
        DelegatesManagerMock()
    }
    
    private func makeBaseCameraDelegateStub() -> BaseCameraDelegateStub {
        BaseCameraDelegateStub()
    }
}
