import UIKit
import AVFoundation

/// The main interface to use the `CameraKage` camera features.
public class CameraKage: UIView {
    private var sessionComposer: SessionComposable = SessionComposer()
    private let sessionQueue = DispatchQueue(label: "LA.cameraKage.sessionQueue")
    private let permissionManager: PermissionsManagerProtocol = PermissionsManager()
    private let delegatesManager: DelegatesManagerProtocol = DelegatesManager()
    private var cameraComponent: CameraComponent!
    
    /// Determines if the `AVCaptureSession` of `CameraKage` is running.
    public var isSessionRunning: Bool { sessionComposer.isSessionRunning }
    
    /// Determines if `CameraKage` has a video recording in progress.
    public private(set) var isRecording: Bool = false
    
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
     Starts a discovery session to get the available camera devices for the client's phone.
     
     - returns: Returns the list of available `AVCaptureDevice`.
     */
    public func getSupportedCameraDevices() -> [AVCaptureDevice] {
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [
            AVCaptureDevice.DeviceType.builtInWideAngleCamera,
            AVCaptureDevice.DeviceType.builtInUltraWideCamera,
            AVCaptureDevice.DeviceType.builtInTelephotoCamera,
            AVCaptureDevice.DeviceType.builtInDualCamera,
            AVCaptureDevice.DeviceType.builtInDualWideCamera,
            AVCaptureDevice.DeviceType.builtInTripleCamera,
            AVCaptureDevice.DeviceType.builtInTrueDepthCamera
        ],
                                                                mediaType: .video,
                                                                position: .unspecified)
        return discoverySession.devices
    }
    
    /**
     Starts the camera session.
     
     - parameter options: Options used for the camera setup
     
     - important: Before calling `startCameraSession`, `requestCameraPermission()` and `requestMicrophonePermission()` methods can be called for custom UI usage. If permission requests aren't used, the system will call the alerts automatically.
     */
    public func startCameraSession(with options: CameraComponentParsedOptions = CameraComponentParsedOptions(nil)) {
        setupCameraComponent(with: options)
        setupSessionDelegate()
        sessionQueue.async { [weak self] in
            guard let self else { return }
            sessionComposer.startSession()
        }
    }
    
    /**
     Stops the camera session and destroys the camera component.
     */
    public func stopCameraSession() {
        destroyCameraComponent()
        sessionQueue.async { [weak self] in
            guard let self else { return }
            sessionComposer.stopSession()
        }
    }
    
    /**
     Captures a photo from the camera. Resulted photo will be delivered via `CameraKageDelegate`.
     
     - parameter flashOption: Indicates what flash option should be used when capturing the photo. Default is `.off`.
     - parameter redEyeCorrection: Determines if red eye correction should be applied or not. Default is `true`.
     */
    public func capturePhoto(_ flashOption: AVCaptureDevice.FlashMode = .off,
                             redEyeCorrection: Bool = true) {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            cameraComponent.capturePhoto(flashOption, redEyeCorrection: redEyeCorrection)
        }
    }
    
    /**
     Starts a video recording for the camera. `CameraKageDelegate` sends a notification when the recording has started.
     */
    public func startVideoRecording() {
        sessionQueue.async { [weak self] in
            guard let self, !isRecording else { return }
            isRecording = true
            cameraComponent.startMovieRecording()
        }
    }
    
    /**
     Stops the video recording. `CameraKageDelegate` sends a notification containing the URL where the video file is stored.
     */
    public func stopVideoRecording() {
        sessionQueue.async { [weak self] in
            guard let self, isRecording else { return }
            isRecording = false
            cameraComponent.stopMovieRecording()
        }
    }
    
    /**
     Flips the camera from back to front and vice-versa.
     
     - important: Camera can't be flipped while recording a video. Session is restarted when flipping the camera.
     */
    public func flipCamera() {
        sessionQueue.async { [weak self] in
            guard let self, !isRecording else { return }
            sessionComposer.pauseSession()
            cameraComponent.flipCamera()
            sessionComposer.resumeSession()
        }
    }
    
    /**
     Adjusts the focus and the exposure of the camera.
     
     - parameter focusMode: Focus mode of the camera. Default is `.autoFocus`.
     - parameter exposureMode: Exposure mode of the camera. Default is `.autoExpose`.
     - parameter devicePoint: The point of the camera where the focus should be switched to.
     - parameter monitorSubjectAreaChange: If set `true`, it registers the camera to receive notifications about area changes for the user to re-focus if needed. Default is `true`.
     */
    public func adjustFocusAndExposure(with focusMode: AVCaptureDevice.FocusMode = .autoFocus,
                                       exposureMode: AVCaptureDevice.ExposureMode = .autoExpose,
                                       at devicePoint: CGPoint,
                                       monitorSubjectAreaChange: Bool = true) {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            cameraComponent.focus(with: focusMode,
                                  exposureMode: exposureMode,
                                  at: devicePoint,
                                  monitorSubjectAreaChange: monitorSubjectAreaChange)
        }
    }
    
    private func setupCameraComponent(with options: CameraComponentParsedOptions) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            cameraComponent = CameraComponent(sessionComposer: sessionComposer,
                                              options: options,
                                              delegate: self)
            addSubview(cameraComponent)
            cameraComponent.layoutToFill(inView: self)
            cameraComponent.configureSession()
        }
    }
    
    private func destroyCameraComponent() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            cameraComponent.removeObserver()
            cameraComponent.removeFromSuperview()
            cameraComponent = nil
        }
    }
    
    private func setupSessionDelegate() {
        sessionComposer.onSessionStart = { [weak self] in
            guard let self else { return }
            delegatesManager.invokeDelegates { $0.cameraSessionDidStart(self) }
        }
        
        sessionComposer.onSessionStop = { [weak self] in
            guard let self else { return }
            delegatesManager.invokeDelegates { $0.cameraSessionDidStop(self) }
        }
        
        sessionComposer.onSessionInterruption = { [weak self] reason in
            guard let self else { return }
            delegatesManager.invokeDelegates { $0.camera(self, sessionWasInterrupted: reason) }
        }
        
        sessionComposer.onSessionInterruptionEnd = { [weak self] in
            guard let self else { return }
            delegatesManager.invokeDelegates { $0.cameraSessionInterruptionEnded(self) }
        }
        
        sessionComposer.onSessionReceiveRuntimeError = { [weak self] isRestartable, avError in
            guard let self else { return }
            if isRestartable {
                sessionQueue.async { [weak self] in
                    guard let self else { return }
                    sessionComposer.resumeSession()
                }
            }
            let sessionError = CameraError.CameraSessionErrorReason.runtimeError(avError)
            delegatesManager.invokeDelegates { $0.camera(self, didEncounterError: .cameraSessionError(reason: sessionError))}
        }
        
        sessionComposer.onDeviceSubjectAreaChange = { [weak self] in
            guard let self else { return }
            delegatesManager.invokeDelegates { $0.cameraDeviceDidChangeSubjectArea(self) }
        }
    }
}

// MARK: - CameraComponentDelegate
extension CameraKage: CameraComponentDelegate {
    func cameraComponent(_ cameraComponent: CameraComponent, didCapturePhoto photo: Data) {
        delegatesManager.invokeDelegates { $0.camera(self, didOutputPhotoWithData: photo)}
    }
    
    func cameraComponent(_ cameraComponent: CameraComponent, didStartRecordingVideo atFileURL: URL) {
        delegatesManager.invokeDelegates { $0.camera(self, didStartRecordingVideoAtFileURL: atFileURL)}
    }
    
    func cameraComponent(_ cameraComponent: CameraComponent, didRecordVideo videoURL: URL) {
        delegatesManager.invokeDelegates { $0.camera(self, didOutputVideoAtFileURL: videoURL)}
    }
    
    func cameraComponent(_ cameraComponent: CameraComponent, didFail withError: CameraError) {
        delegatesManager.invokeDelegates { $0.camera(self, didEncounterError: withError) }
    }
}
