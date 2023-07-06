import UIKit

/// The main interface to use the `CameraKage` camera features.
public class CameraKage {
    private var permissionManager: PermissionsManagerProtocol = PermissionsManager()
    private var compressionManager: CompressionManagerInterface = CompressionManager()
    private var sessionComposer: SessionComposer = SessionComposer()
    
    /// Available cameras for the client's phone.
    public var availableCameraDevices: [CameraDevice] { CameraDevice.availableDevices }
    
    public static var shared = CameraKage()
    
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
    
    
    /**
     Compress a video located at a given URL.
     
     - parameter url: The location of the video to be compressed.
     - parameter resolution: The desired output resolution of the video.
     - parameter bitrate: The desired bitrate of the compressed video.
     - parameter completion: Result containing either the URL of the compressed video or an error.
     */
    public func compressVideo(atURL url: URL,
                              resolution: Resolution,
                              bitrate: BitRate,
                              completion: @escaping ((Result<URL, CompressionError>) -> Void)) {
        compressionManager.compressVideo(withURL: url,
                                         resolution: resolution,
                                         bitrate: bitrate,
                                         handler: completion)
    }
    
    /**
     Compress a photo with given data.
     
     - parameter data: The data of the image to be compressed.
     - parameter quality: The compression quality of the photo.
     - parameter resolution: The desired output resolution of the photo.
     - parameter completion: Result containing either the data of the compressed photo or an error.
     */
    public func compressPhoto(withData data: Data,
                              quality: ImageQuality,
                              resolution: Resolution,
                              completion: @escaping ((Result<Data, CompressionError>) -> Void)) {
        compressionManager.compressImage(withData: data,
                                         compressionQuality: quality,
                                         resolution: resolution,
                                         completion: completion)
    }
}

// MARK: - Internal tests inits
extension CameraKage {
    internal convenience init(permissionManager: PermissionsManagerProtocol) {
        self.init()
        self.permissionManager = permissionManager
    }
}
