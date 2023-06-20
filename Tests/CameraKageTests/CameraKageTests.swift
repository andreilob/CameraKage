import XCTest
@testable import CameraKage

final class CameraKageTests: XCTestCase {
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
    func makeSUT(permissionsManager: PermissionManagerMock) -> CameraKage {
        let sut = CameraKage(permissionManager: permissionsManager)
        trackMemoryLeaks(sut)
        return sut
    }
    
    func createPermisssionsManagerMock() -> PermissionManagerMock {
        let mock = PermissionManagerMock()
        trackMemoryLeaks(mock)
        return mock
    }
}
