//
//  SessionCameraViewTests.swift
//  
//
//  Created by Lobont Andrei on 19.06.2023.
//

import XCTest
@testable import CameraKage

final class SessionCameraViewTests: XCTestCase {
    func test_init_setDelegate_embedPreviewLayer() {
        let sessionMock = makeSessionMock()
        let videoLayerMock = makeVideoLayerMock()
        let options = CameraComponentParsedOptions(nil)
        let videoInputMock = makeVideoInputMock(options: options)
        let camera = makeSessionCamera(session: sessionMock,
                                       videoInput: videoInputMock,
                                       videoLayer: videoLayerMock,
                                       options: options)
        XCTAssertNil(sessionMock.delegate, "View not yet initialized, no session delegate should be set.")
        XCTAssertNil(videoLayerMock.parentLayer, "View not yet initialized, preview layer should have no parent layer.")
        
        let sut = makeSUT(camera: camera)
        
        XCTAssert(sessionMock.delegate === sut)
        XCTAssertEqual(videoLayerMock.parentLayer, sut.layer)
    }
    
    func test_session_startAndStopSession_addAndRemoveSessionObservers() {
        let sessionMock = makeSessionMock()
        let videoLayerMock = makeVideoLayerMock()
        let options = CameraComponentParsedOptions(nil)
        let videoInputMock = makeVideoInputMock(options: options)
        let camera = makeSessionCamera(session: sessionMock,
                                       videoInput: videoInputMock,
                                       videoLayer: videoLayerMock,
                                       options: options)
        let sessionQueue = DispatchQueue(label: "testSessionQueue")
        let sut = makeSUT(camera: camera, sessionQueue: sessionQueue)
        
        XCTAssertFalse(sessionMock.isRunning, "Session not yet started")
        XCTAssertFalse(sessionMock.isObservingSession, "Session not yet started")
        
        sut.startCamera()
        sessionQueue.sync {}
        XCTAssertTrue(sessionMock.isRunning)
        XCTAssertTrue(sessionMock.isObservingSession)
        
        sut.stopCamera()
        sessionQueue.sync {}
        XCTAssertFalse(sessionMock.isRunning)
        XCTAssertFalse(sessionMock.isObservingSession)
    }
    
    func test_delegatesManager_addAndRemoveDelegate() {
        let sessionMock = makeSessionMock()
        let videoLayerMock = makeVideoLayerMock()
        let options = CameraComponentParsedOptions(nil)
        let videoInputMock = makeVideoInputMock(options: options)
        let camera = makeSessionCamera(session: sessionMock,
                                       videoInput: videoInputMock,
                                       videoLayer: videoLayerMock,
                                       options: options)
        let delegatesManager = makeDelegatesManagerMock()
        let delegateStub = makeDelegateStub()
        let sut = makeSUT(camera: camera, delegatesManager: delegatesManager)
        
        XCTAssertEqual(delegatesManager.delegates.count, 0, "No delegates added yet.")
        
        sut.registerDelegate(delegateStub)
        XCTAssertEqual(delegatesManager.delegates.count, 1)
        
        sut.unregisterDelegate(delegateStub)
        XCTAssertEqual(delegatesManager.delegates.count, 0)
    }
    
    func test_delegatesManager_invokeDelegates() {
        let sessionMock = makeSessionMock()
        let videoLayerMock = makeVideoLayerMock()
        let options = CameraComponentParsedOptions(nil)
        let videoInputMock = makeVideoInputMock(options: options)
        let camera = makeSessionCamera(session: sessionMock,
                                       videoInput: videoInputMock,
                                       videoLayer: videoLayerMock,
                                       options: options)
        let delegatesManager = makeDelegatesManagerMock()
        let delegateStub = makeDelegateStub()
        let sut = makeSUT(camera: camera, delegatesManager: delegatesManager)
        
        XCTAssertFalse(delegateStub.invoked)
        
        sut.registerDelegate(delegateStub)
        
        delegatesManager.invokeDelegates { delegate in
            guard let delegate = delegate as? SessionCameraDelegateStub else {
                XCTFail("Failed to cast delegate")
                return
            }
            delegate.invoked = true
        }
        XCTAssertTrue(delegateStub.invoked)
    }
}

extension SessionCameraViewTests {
    private func makeSUT(camera: SessionCameraInterface) -> SessionCameraView {
        let sut = SessionCameraView(sessionCamera: camera)
        trackMemoryLeaks(sut)
        return sut
    }
    
    private func makeSUT(camera: SessionCameraInterface, sessionQueue: DispatchQueue) -> SessionCameraView {
        let sut = SessionCameraView(sessionCamera: camera, sessionQueue: sessionQueue)
        trackMemoryLeaks(sut)
        return sut
    }
    
    private func makeSUT(camera: SessionCameraInterface, delegatesManager: DelegatesManagerProtocol) -> SessionCameraView {
        let sut = SessionCameraView(sessionCamera: camera, delegatesManager: delegatesManager)
        trackMemoryLeaks(sut)
        return sut
    }
    
    private func makeSessionCamera(session: Session,
                                   videoInput: VideoInput,
                                   videoLayer: VideoLayer,
                                   options: CameraComponentParsedOptions) -> SessionCameraInterface {
        let camera = SessionCamera(session: session,
                                   videoInput: videoInput,
                                   videoLayer: videoLayer,
                                   options: options)
        trackMemoryLeaks(camera)
        return camera
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
    
    private func makeDelegatesManagerMock() -> DelegatesManagerMock {
        let mock = DelegatesManagerMock()
        trackMemoryLeaks(mock)
        return mock
    }
    
    private func makeDelegateStub() -> SessionCameraDelegateStub {
        let stub = SessionCameraDelegateStub()
        trackMemoryLeaks(stub)
        return stub
    }
}
