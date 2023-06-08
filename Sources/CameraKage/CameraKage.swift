import UIKit

/// The main interface to use the `CameraKage` camera features.
public class CameraKage: UIView {
    private var permissionManager: PermissionsManagerProtocol = PermissionsManager()
    private var delegatesManager: DelegatesManagerProtocol = DelegatesManager()
    private var cameraComposer: CameraComposerProtocol!
    
    /// Determines if the CaptureSession of `CameraKage` is running.
    public var isSessionRunning: Bool { cameraComposer.isSessionRunning }
    
    /// Determines if `CameraKage` has a video recording in progress.
    public var isRecording: Bool { cameraComposer.isRecording }
    
    /// Available cameras for the client's phone.
    public var availableCameraDevices: [CameraDevice] { CameraDevice.availableDevices }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupComposer()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupComposer()
    }
    
    /**
     Register a listener for the `CameraKage` to receive notifications regarding the camera session.
     
     - parameter delegate: The object that will receive the notifications.
     */
    public func registerDelegate(_ delegate: CameraKageDelegate) {
        delegatesManager.registerDelegate(delegate)
    }
    
    /**
     Unregisters a listener from receiving `CameraKage` notifications.
     
     - parameter delegate: The object to be removed.
     */
    public func unregisterDelegate(_ delegate: CameraKageDelegate) {
        delegatesManager.unregisterDelegate(delegate)
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
     Starts the camera session.
     
     - parameter options: Options used for the camera setup
     
     - important: Before calling `startCameraSession`, `requestCameraPermission()` and `requestMicrophonePermission()` methods can be called for custom UI usage. If permission requests aren't used, the system will call the alerts automatically.
     */
    public func startCameraSession(with options: CameraComponentParsedOptions = CameraComponentParsedOptions(nil)) {
        cameraComposer.startCameraSession(with: options)
    }
    
    /**
     Stops the camera session and destroys the camera component.
     */
    public func stopCameraSession() {
        cameraComposer.stopCameraSession()
    }
    
    /**
     Captures a photo from the camera. Resulted photo will be delivered via `CameraKageDelegate`.
     
     - parameter flashOption: Indicates what flash option should be used when capturing the photo. Default is `.off`.
     - parameter redEyeCorrection: Determines if red eye correction should be applied or not. Default is `true`.
     */
    public func capturePhoto(_ flashOption: FlashMode = .off,
                             redEyeCorrection: Bool = true) {
        cameraComposer.capturePhoto(flashOption, redEyeCorrection: redEyeCorrection)
    }
    
    /**
     Starts a video recording for the camera. `CameraKageDelegate` sends a notification when the recording has started.
     */
    public func startVideoRecording() {
        cameraComposer.startVideoRecording()
    }
    
    /**
     Stops the video recording. `CameraKageDelegate` sends a notification containing the URL where the video file is stored.
     */
    public func stopVideoRecording() {
        cameraComposer.stopVideoRecording()
    }
    
    /**
     Flips the camera from back to front and vice-versa.
     
     - important: Camera can't be flipped while recording a video. Session is restarted when flipping the camera.
     */
    public func flipCamera() {
        cameraComposer.flipCamera()
    }
    
    /**
     Adjusts the focus and the exposure of the camera.
     
     - parameter focusMode: Focus mode of the camera. Default is `.autoFocus`.
     - parameter exposureMode: Exposure mode of the camera. Default is `.autoExpose`.
     - parameter devicePoint: The point of the camera where the focus should be switched to.
     - parameter monitorSubjectAreaChange: If set `true`, it registers the camera to receive notifications about area changes for the user to re-focus if needed. Default is `true`.
     */
    public func adjustFocusAndExposure(with focusMode: FocusMode = .autoFocus,
                                       exposureMode: ExposureMode = .autoExpose,
                                       at devicePoint: CGPoint,
                                       monitorSubjectAreaChange: Bool = true) {
        cameraComposer.adjustFocusAndExposure(with: focusMode,
                                              exposureMode: exposureMode,
                                              at: devicePoint,
                                              monitorSubjectAreaChange: monitorSubjectAreaChange)
    }
    
    private func setupComposer() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            cameraComposer = CameraComposer()
            cameraComposer.delegate = self
            addSubview(cameraComposer)
            cameraComposer.layoutToFill(inView: self)
        }
    }
}

// MARK: - CameraComposerDelegate
extension CameraKage: CameraComposerDelegate {
    func cameraComposer(_ cameraComposer: CameraComposer, didCapturePhoto photo: Data) {
        delegatesManager.invokeDelegates { $0.camera(self, didOutputPhotoWithData: photo) }
    }
    
    func cameraComposer(_ cameraComposer: CameraComposer, didStartRecordingVideo atFileURL: URL) {
        delegatesManager.invokeDelegates { $0.camera(self, didStartRecordingVideoAtFileURL: atFileURL) }
    }
    
    func cameraComposer(_ cameraComposer: CameraComposer, didRecordVideo videoURL: URL) {
        delegatesManager.invokeDelegates { $0.camera(self, didOutputVideoAtFileURL: videoURL) }
    }
    
    func cameraComposer(_ cameraComposer: CameraComposer, didZoomAtScale scale: CGFloat, outOfMaximumScale maxScale: CGFloat) {
        delegatesManager.invokeDelegates { $0.camera(self, didZoomAtScale: scale, outOfMaximumScale: maxScale) }
    }
    
    func cameraComposer(_ cameraComposer: CameraComposer, didReceiveError error: CameraError) {
        delegatesManager.invokeDelegates { $0.camera(self, didEncounterError: error) }
    }
    
    func cameraComposer(_ cameraComposer: CameraComposer, didReceiveSessionInterruption reason: SessionInterruptionReason) {
        delegatesManager.invokeDelegates { $0.camera(self, sessionWasInterrupted: reason) }
    }
    
    func cameraComposerDidFinishSessionInterruption(_ cameraComposer: CameraComposer) {
        delegatesManager.invokeDelegates { $0.cameraSessionInterruptionEnded(self) }
    }
    
    func cameraComposerDidStartCameraSession(_ cameraComposer: CameraComposer) {
        delegatesManager.invokeDelegates { $0.cameraSessionDidStart(self) }
    }
    
    func cameraComposerDidStopCameraSession(_ cameraComposer: CameraComposer) {
        delegatesManager.invokeDelegates { $0.cameraSessionDidStop(self) }
    }
    
    func cameraComposerDidChangeDeviceAreaOfInterest(_ cameraComposer: CameraComposer) {
        delegatesManager.invokeDelegates { $0.cameraDeviceDidChangeSubjectArea(self) }
    }
}

// MARK: - Internal tests inits
extension CameraKage {
    internal convenience init(permissionManager: PermissionsManagerProtocol,
                              delegatesManager: DelegatesManagerProtocol,
                              cameraComposer: CameraComposerProtocol) {
        self.init(frame: .zero)
        self.permissionManager = permissionManager
        self.delegatesManager = delegatesManager
        self.cameraComposer = cameraComposer
    }
    
    internal convenience init(delegatesManager: DelegatesManagerProtocol) {
        self.init(frame: .zero)
        self.delegatesManager = delegatesManager
    }
    
    internal convenience init(permissionManager: PermissionsManagerProtocol) {
        self.init(frame: .zero)
        self.permissionManager = permissionManager
    }
    
    internal convenience init(cameraComposer: CameraComposerProtocol) {
        self.init(frame: .zero)
        self.cameraComposer = cameraComposer
    }
}
