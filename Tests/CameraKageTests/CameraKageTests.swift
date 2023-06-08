import XCTest
@testable import CameraKage

final class CameraKageTests: XCTestCase {
    func test_delegatesManager_registerAndUnregisterDelegate() {
        let managerMock = createDelegatesManagerMock()
        let sut = makeSUT(delegatesManager: managerMock)
        
        XCTAssertEqual(managerMock.delegates.count, 0, "Mock was just created, so count should be 0.")
        
        let delegateMock = createDelegateMock()
        sut.unregisterDelegate(delegateMock)
        XCTAssertEqual(managerMock.delegates.count, 0, "Delegate mock wasn't registered as a delegate so count was never modified")
        
        sut.registerDelegate(delegateMock)
        XCTAssertEqual(managerMock.delegates.count, 1)
        
        sut.unregisterDelegate(delegateMock)
        XCTAssertEqual(managerMock.delegates.count, 0)
    }
    
    func test_delegatesManager_delegatesInvocation() {
        let managerMock = createDelegatesManagerMock()
        let delegateMock = createDelegateMock()
        let sut = makeSUT(delegatesManager: managerMock)
        
        XCTAssertFalse(delegateMock.invoked, "Delegate mock was just created, so it shouldn't have been invoked yet.")
        
        sut.registerDelegate(delegateMock)
        managerMock.invokeDelegates { delegate in
            let delegate = delegate as? CameraKageDelegateMock
            XCTAssertEqual(delegate?.invoked, true)
        }
        
        XCTAssertTrue(delegateMock.invoked)
    }
    
    func test_permissionsManager_requestVideoPermission_withCompletion() {
        let managerMock = createPermisssionsManagerMock()
        let sut = makeSUT(permissionsManager: managerMock)
        
        XCTAssertEqual(managerMock.getAuthorizationStatus(for: .video), .notDetermined, "Request hasn't been made, so status should be notDetermined")
        
        sut.requestCameraPermission { granted in
            XCTAssertTrue(granted)
        }
        XCTAssertEqual(managerMock.getAuthorizationStatus(for: .video), .authorized)
    }
    
    func test_permissionsManager_requestVideoPermission_withConcurrency() async {
        let managerMock = createPermisssionsManagerMock()
        let sut = makeSUT(permissionsManager: managerMock)
        
        XCTAssertEqual(managerMock.getAuthorizationStatus(for: .video), .notDetermined, "Request hasn't been made, so status should be notDetermined")
        
        let granted = await sut.requestCameraPermission()
        XCTAssertTrue(granted)
        XCTAssertEqual(managerMock.getAuthorizationStatus(for: .video), .authorized)
    }
    
    func test_permissionsManager_requestAudioPermission_withCompletion() {
        let managerMock = createPermisssionsManagerMock()
        let sut = makeSUT(permissionsManager: managerMock)
        
        XCTAssertEqual(managerMock.getAuthorizationStatus(for: .audio), .notDetermined, "Request hasn't been made, so status should be notDetermined")
        
        sut.requestMicrophonePermission { granted in
            XCTAssertTrue(granted)
        }
        XCTAssertEqual(managerMock.getAuthorizationStatus(for: .audio), .authorized)
    }
    
    func test_permissionsManager_requestAudioPermission_withConcurrency() async {
        let managerMock = createPermisssionsManagerMock()
        let sut = makeSUT(permissionsManager: managerMock)
        
        XCTAssertEqual(managerMock.getAuthorizationStatus(for: .audio), .notDetermined, "Request hasn't been made, so status should be notDetermined")
        
        let granted = await sut.requestMicrophonePermission()
        XCTAssertTrue(granted)
        XCTAssertEqual(managerMock.getAuthorizationStatus(for: .audio), .authorized)
    }
}

extension CameraKageTests {
    func makeSUT(delegatesManager: DelegatesManagerMock,
                 permissionsManager: PermissionManagerMock,
                 cameraComposer: CameraComposer) -> CameraKage {
        let sut = CameraKage(permissionManager: permissionsManager,
                             delegatesManager: delegatesManager,
                             cameraComposer: cameraComposer)
        trackMemoryLeaks(sut)
        return sut
    }
    
    func makeSUT(delegatesManager: DelegatesManagerMock) -> CameraKage {
        let sut = CameraKage(delegatesManager: delegatesManager)
        trackMemoryLeaks(sut)
        return sut
    }
    
    func makeSUT(permissionsManager: PermissionManagerMock) -> CameraKage {
        let sut = CameraKage(permissionManager: permissionsManager)
        trackMemoryLeaks(sut)
        return sut
    }
    
    func createDelegatesManagerMock() -> DelegatesManagerMock {
        DelegatesManagerMock()
    }
    
    func createDelegateMock() -> CameraKageDelegateMock {
        CameraKageDelegateMock()
    }
    
    func createPermisssionsManagerMock() -> PermissionManagerMock {
        PermissionManagerMock()
    }
}
