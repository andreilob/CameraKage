import XCTest
@testable import CameraKage

final class CameraKageTests: XCTestCase {
    private var delegatesManager: DelegatesManagerProtocol!
    private var permissionsManagerMock: PermissionsManagerProtocol!
    
    override func setUp() {
        super.setUp()
        delegatesManager = DelegatesManagerMock()
        permissionsManagerMock = PermissionManagerMock()
    }
    
    override func tearDown() {
        super.tearDown()
        delegatesManager = nil
        permissionsManagerMock = nil
    }
    
    func testDelegateRegistration() {
        XCTAssertEqual(delegatesManager.delegates.allObjects.count, 0)
        
        let firstDelegate = CameraKageDelegateMock()
        let secondDelegate = CameraKageDelegateMock()
        delegatesManager.registerDelegate(firstDelegate)
        delegatesManager.registerDelegate(secondDelegate)
        
        XCTAssertEqual(delegatesManager.delegates.allObjects.count, 2)
        
        delegatesManager.unregisterDelegate(firstDelegate)
        XCTAssertEqual(delegatesManager.delegates.allObjects.count, 1)
    }
    
    func testDelegateInvocation() {
        let firstDelegate = CameraKageDelegateMock()
        let secondDelegate = CameraKageDelegateMock()
        delegatesManager.registerDelegate(firstDelegate)
        XCTAssertFalse(firstDelegate.invoked)
        XCTAssertFalse(secondDelegate.invoked)
        delegatesManager.invokeDelegates { delegate in
            let delegate = delegate as? CameraKageDelegateMock
            XCTAssertEqual(delegate?.invoked, true)
        }
        delegatesManager.registerDelegate(secondDelegate)
        XCTAssertTrue(firstDelegate.invoked)
        XCTAssertFalse(secondDelegate.invoked)
    }
    
    func testGetCameraPermissionStatusWithCallback() {
        XCTAssertEqual(permissionsManagerMock.getAuthorizationStatus(for: .video), .denied)
        XCTAssertEqual(permissionsManagerMock.getAuthorizationStatus(for: .audio), .denied)
        permissionsManagerMock.requestAccess(for: .video) { granted in
            XCTAssertTrue(granted)
            XCTAssertEqual(self.permissionsManagerMock.getAuthorizationStatus(for: .video), .authorized)
            XCTAssertEqual(self.permissionsManagerMock.getAuthorizationStatus(for: .audio), .denied)
        }
    }
    
    func testGetCameraPermissionStatus() async {
        XCTAssertEqual(permissionsManagerMock.getAuthorizationStatus(for: .video), .denied)
        XCTAssertEqual(permissionsManagerMock.getAuthorizationStatus(for: .audio), .denied)
        let granted = await permissionsManagerMock.requestAccess(for: .video)
        XCTAssertTrue(granted)
        XCTAssertEqual(permissionsManagerMock.getAuthorizationStatus(for: .video), .authorized)
        XCTAssertEqual(permissionsManagerMock.getAuthorizationStatus(for: .audio), .denied)
    }
    
    func testGetMicrophonePermissionStatusWithCallback() {
        XCTAssertEqual(permissionsManagerMock.getAuthorizationStatus(for: .video), .denied)
        XCTAssertEqual(permissionsManagerMock.getAuthorizationStatus(for: .audio), .denied)
        permissionsManagerMock.requestAccess(for: .audio) { granted in
            XCTAssertTrue(granted)
            XCTAssertEqual(self.permissionsManagerMock.getAuthorizationStatus(for: .video), .denied)
            XCTAssertEqual(self.permissionsManagerMock.getAuthorizationStatus(for: .audio), .authorized)
        }
    }
    
    func testGetMicrophonePermissionStatus() async {
        XCTAssertEqual(permissionsManagerMock.getAuthorizationStatus(for: .audio), .denied)
        let granted = await permissionsManagerMock.requestAccess(for: .audio)
        XCTAssertTrue(granted)
        XCTAssertEqual(permissionsManagerMock.getAuthorizationStatus(for: .video), .denied)
        XCTAssertEqual(permissionsManagerMock.getAuthorizationStatus(for: .audio), .authorized)
    }
}

extension XCTestCase {
    public func trackMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }
}
