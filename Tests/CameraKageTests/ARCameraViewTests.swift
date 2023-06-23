//
//  ARCameraViewTests.swift
//  
//
//  Created by Lobont Andrei on 23.06.2023.
//

import XCTest
@testable import CameraKage

final class ARCameraViewTests: XCTestCase {
    func test_init_cameraDelegate_viewEmbeding() {
        let previewerMock = makeARPreviewerMock()
        let assetWriterMock = makeAssetWriterMock()
        let options = ARCameraComponentParsedOptions(nil)
        let cameraMock = makeARCamera(arPreviewer: previewerMock,
                                      assetWriter: assetWriterMock,
                                      options: options)
        
        XCTAssertNil(cameraMock.delegate, "Delegate is only set after SUT init.")
        XCTAssertNil(previewerMock.embedingView, "View will be embedded only after SUT init.")
        
        let sut = makeSUT(arCamera: cameraMock)
        
        XCTAssert(cameraMock.delegate === sut)
        XCTAssert(previewerMock.embedingView === sut)
    }
    
    func test_camera_startAndStop() {
        let previewerMock = makeARPreviewerMock()
        let assetWriterMock = makeAssetWriterMock()
        let options = ARCameraComponentParsedOptions(nil)
        let cameraMock = makeARCamera(arPreviewer: previewerMock,
                                      assetWriter: assetWriterMock,
                                      options: options)
        let sut = makeSUT(arCamera: cameraMock)
        
        XCTAssertFalse(cameraMock.isSessionRunning, "Camera not yet started.")
        
        sut.startCamera()
        XCTAssertTrue(cameraMock.isSessionRunning)
        
        sut.stopCamera()
        XCTAssertFalse(cameraMock.isSessionRunning)
    }
    
    func test_assetWriter_videoRecording() {
        let previewerMock = makeARPreviewerMock()
        let assetWriterMock = makeAssetWriterMock()
        let options = ARCameraComponentParsedOptions(nil)
        let cameraMock = makeARCamera(arPreviewer: previewerMock,
                                      assetWriter: assetWriterMock,
                                      options: options)
        let sut = makeSUT(arCamera: cameraMock)
        
        XCTAssertFalse(assetWriterMock.isRecording)
        
        sut.startVideoRecording()
        XCTAssertTrue(assetWriterMock.isRecording)
        
        sut.stopVideoRecording()
        XCTAssertFalse(assetWriterMock.isRecording)
    }
    
    func test_previewer_loadMask() {
        let previewerMock = makeARPreviewerMock()
        let assetWriterMock = makeAssetWriterMock()
        let options = ARCameraComponentParsedOptions(nil)
        let cameraMock = makeARCamera(arPreviewer: previewerMock,
                                      assetWriter: assetWriterMock,
                                      options: options)
        let sut = makeSUT(arCamera: cameraMock)
        
        XCTAssertNil(previewerMock.currentMaskNameAndFileType)
        
        sut.loadARMask(name: "someMask", fileType: "scn")
        
        XCTAssertEqual(previewerMock.currentMaskNameAndFileType, "someMask.scn")
    }
}

extension ARCameraViewTests {
    private func makeSUT(arCamera: ARCameraInterface) -> ARCameraView {
        let sut = ARCameraView(arCamera: arCamera)
        trackMemoryLeaks(sut)
        return sut
    }
    
    private func makeARCamera(arPreviewer: ARPreviewer,
                              assetWriter: AssetWriterInterface,
                              options: ARCameraComponentParsedOptions) -> ARCamera {
        let camera = ARCamera(arPreviewView: arPreviewer,
                              assetWriter: assetWriter,
                              options: options)
        trackMemoryLeaks(camera)
        return camera
    }
    
    private func makeARPreviewerMock() -> ARPreviewViewMock {
        let mock = ARPreviewViewMock()
        trackMemoryLeaks(mock)
        return mock
    }
    
    private func makeAssetWriterMock() -> ARAssetWriterMock {
        let mock = ARAssetWriterMock()
        trackMemoryLeaks(mock)
        return mock
    }
}
