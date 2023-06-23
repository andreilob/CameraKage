import UIKit

/// The main interface to use the `CameraKage` camera features.
public class CameraKage: UIView {
    private var permissionManager: PermissionsManagerProtocol = PermissionsManager()
    private var sessionComposer: SessionComposer = SessionComposer()
    
    /// Available cameras for the client's phone.
    public var availableCameraDevices: [CameraDevice] { CameraDevice.availableDevices }
    
    /**
     Create a view with a full camera integrated, capable of capturing photos and creating video recordings.
     
     - parameter options: The options used in the camera setup.
     
     - returns: Returns a result containing either the camera view or an error that might have occured in the camera setup process.
     */
    public func createCameraView(with options: CameraComponentParsedOptions = CameraComponentParsedOptions(nil)) -> Result<CameraView, CameraError> {
        sessionComposer.createCameraView(options: options)
    }
    
    /**
     Create a view with a video camera integrated, capable of creating video recordings.
     
     - parameter options: The options used in the camera setup.
     
     - returns: Returns a result containing either the camera view or an error that might have occured in the camera setup process.
     */
    public func createVideoCameraView(with options: CameraComponentParsedOptions = CameraComponentParsedOptions(nil)) -> Result<VideoCameraView, CameraError> {
        sessionComposer.createVideoCameraView(options: options)
    }
    
    /**
     Create a view with a photo camera integrated, capable of capturing photos.
     
     - parameter options: The options used in the camera setup.
     
     - returns: Returns a result containing either the camera view or an error that might have occured in the camera setup process.
     */
    public func createPhotoCameraView(with options: CameraComponentParsedOptions = CameraComponentParsedOptions(nil)) -> Result<PhotoCameraView, CameraError> {
        sessionComposer.createPhotoCameraView(options: options)
    }
    
    /**
     Create a view with a metadata camera integrated, capable of detcting and decoding different code types visible to the camera.
     
     - parameter options: The options used in the camera setup.
     - parameter metadataTypes: An array containing the metadata types that the camera should decode.
     
     - returns: Returns a result containing either the camera view or an error that might have occured in the camera setup process.
     */
    public func createMetadataCameraView(with options: CameraComponentParsedOptions = CameraComponentParsedOptions(nil),
                                         metadataTypes: [MetadataType]) -> Result<MetadataCameraView, CameraError> {
        sessionComposer.createMetadataCameraView(options: options, metadataTypes: metadataTypes)
    }
    
    /**
     Create a view with an AR camera integrated, capable of adding 3D face masks and capturing content with them.
     
     - parameter options: The options used in the camera setup.
     
     - returns: Returns the ARCameraView.
     */
    public func createARCameraView(options: ARCameraComponentParsedOptions = ARCameraComponentParsedOptions(nil)) -> ARCameraView {
        sessionComposer.createARCameraView(options: options)
    }
    
    /**
     Prompts the user with the system alert to grant permission for the camera usage.
     
     - returns: Returns asynchronously a `Bool` specifying if the access was granted or not.
     
     - important: Info.plist key `NSCameraUsageDescription` must be set otherwise the application will crash.
     */
    public func requestCameraPermission() async -> Bool {
        await permissionManager.requestAccess(for: .video)
    }
    
    /**
     Prompts the user with the system alert to grant permission for the camera usage.
     
     - parameter completion: Callback containing a `Bool` result specifying if access was granted or not.
     
     - important: Info.plist key `NSCameraUsageDescription` must be set otherwise the application will crash.
     */
    public func requestCameraPermission(completion: @escaping((Bool) -> Void)) {
        permissionManager.requestAccess(for: .video, completion: completion)
    }
    
    /**
     Prompts the user with the system alert to grant permission for the microphone usage.
     
     - returns: Returns asynchronously a `Bool` specifying if the access was granted or not.
     
     - important: Info.plist key `NSMicrophoneUsageDescription` must be set otherwise the application will crash.
     */
    public func requestMicrophonePermission() async -> Bool {
        await permissionManager.requestAccess(for: .audio)
    }
    
    /**
     Prompts the user with the system alert to grant permission for the microphone usage.
     
     - parameter completion: Completion containing `Bool` result specifying if access was granted or not.
     
     - important: Info.plist key `NSMicrophoneUsageDescription` must be set otherwise the application will crash.
     */
    public func requestMicrophonePermission(completion: @escaping((Bool) -> Void)) {
        permissionManager.requestAccess(for: .audio, completion: completion)
    }
    
    /**
     Checks the current camera permission status.
     
     - returns: Returns the current status.
     
     - important: `getCameraPermissionStatus()` won't request access to the user. Use `requestCameraPermission()` to prompt the system alert.
     */
    public func getCameraPermissionStatus() -> PermissionStatus {
        permissionManager.getAuthorizationStatus(for: .video)
    }
    
    /**
     Checks the current microphone permission status.
     
     - returns: Returns the current status.
     
     - important: `getMicrophonePermissionStatus()` won't request access to the user. Use `requestMicrophonePermission()` to prompt the system alert.
     */
    public func getMicrophonePermissionStatus() -> PermissionStatus {
        permissionManager.getAuthorizationStatus(for: .audio)
    }
}

// MARK: - Internal tests inits
extension CameraKage {
    internal convenience init(permissionManager: PermissionsManagerProtocol) {
        self.init(frame: .zero)
        self.permissionManager = permissionManager
    }
}
