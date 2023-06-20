<p align="center">
<img src="https://raw.githubusercontent.com/andreilob/CameraKage/main/images/logo.png" alt="CameraKage" title="CameraKage" width="600"/>
</p>

<p align="center">
<a href="https://github.com/andreilob/CameraKage/actions/workflows/builder.yml?query=workflows+Swift"><img src="https://img.shields.io/github/actions/workflow/status/andreilob/CameraKage/builder.yml"></a>
<a href="https://swift.org/package-manager/"><img src="https://img.shields.io/badge/SPM-Supported-red"></a>
<a href="https://www.swift.org/blog/swift-5.5-released/"><img src="https://img.shields.io/badge/Swift-5.5-green"></a>
<a href="https://support.apple.com/en-us/HT212788"><img src="https://img.shields.io/badge/iOS-15%2B-informational"></a>               
<a href="https://raw.githubusercontent.com/andreilob/CameraKage/main/LICENSE"><img src="https://img.shields.io/badge/license-MIT-black"></a>
<a href="https://github.com/andreilob/CameraKage/releases/tag/1.1.0"><img src="https://img.shields.io/badge/Version-1.1.1-informational"></a>         
</p>

<p align="center">
CameraKage is a fully customizable, pure Swift, plug-and-play camera view.
</p>

## Functionalities

- [x] Fully customizable and composable camera views.
- [x] Premission handling.
- [x] Delegate notifications.
- [x] Photo and video capture.
- [x] Metadata camera scanner (QR, barcodes, etc.)
- [x] Camera flipping.
- [x] Adjustments for exposure and focus of the camera.
- [x] Capture session error and interruptions notifiers.
- [x] Flash usage for both photo and video.

### CameraKage Setup

Start setting up CameraKage by importing the package and creating a main module instance.

```swift
import CameraKage

let cameraKage = CameraKage()
```
Using the module instance you can handle camera and microphone permissions and create the type of camera view you would need. (Photo Camera, Video Camera or a full camera capable of both photo capture and video recordings)
```swift
let cameraPermissionGranted = await cameraKage.requestCameraPermission()
let microphonePermissionGranted = await cameraKage.requestMicrophonePermission()
if cameraPermissionGranted, microphonePermissionGranted {
    let cameraCreationResult = cameraKage.createCameraView(with: CameraComponentParsedOptions([
        .cameraDevice(.backUltraWideCamera),
        .flipCameraDevice(.frontCamera),
        .maxVideoDuration(20.0),
        .pinchToZoomEnabled(true)
    ]))
    switch cameraCreationResult {
    case .success(let cameraView):
        // Add camera to your view
    case .failure(let error):
        // Handle error that might occur
    }
}
```

To receive notifications from the camera, you have to register as a listener and implement the delegate protocol of the specific camera.

```swift
cameraView.registerDelegate(self)
```
After the setup, the last thing to be done is to call the camera `startCamera()` method

```swift
cameraView.startCamera()
```
With these steps you should have you camera up an running, what's left is just to call the capturePhoto or startVideoRecording methods.

### CameraKage Delegate

CameraKage provides a handful of useful notifications regarding the camera and the on-going camera session:

```swift
    /**
     Called when a pinch to zoom action happened on the camera.
     
     - parameter scale: The current zoom scale reported by the pinch gesture.
     - parameter maxScale: The maximum zoom scale of the camera.
     */
    func cameraDidZoom(atScale scale: CGFloat, outOfMaximumScale maxScale: CGFloat)
    
    /**
     Called when the camera encountered an error.
     
     - parameter error: The error that was encountered.
     */
    func cameraDidEncounterError(error: CameraError)
    
    /**
     Called when the camera session was interrupted. This can happen from various reason but most common ones would be phone calls while using the camera, other apps taking control over the phone camera or app moving to background.
     
     - parameter reason: The reason for the session interruption.
     
     - important: When this is called, the camera will freezee so some UI overlay might be necessary on the client side.
     */
    func cameraDidReceiveSessionInterruption(withReason reason: SessionInterruptionReason)
    
    /**
     Called when the camera session interruption has ended. When this is called the camera will resume working.
     */
    func cameraDidFinishSessionInterruption()
    
    /**
     Called when the camera session was started and the actual camera will be visible on screen.
     */
    func cameraDidStartCameraSession()
    
    /**
     Called when the camera session has stopped.
     */
    func cameraDidStopCameraSession()
    
    /**
     Called when the instance of AVCaptureDevice has detected a substantial change to the video subject area. This notification is only sent if you first set monitorSubjectAreaChange to `true` in the `focus()` camera method.
     */
    func cameraDidChangeDeviceAreaOfInterest()
```

And also there are the camera specific delegate methods:

### Photo Camera
```swift
    /**
     Called when the camera has outputted a photo.
     
     - parameter data: The data representation of the photo.
     */
    func cameraDidCapturePhoto(withData data: Data)
```

### Video Camera
```swift
    /**
     Called when the camera has started a video recording.
     
     - parameter url: The URL file location where the video is being recorded.
     */
    func cameraDidStartVideoRecording(atFileURL url: URL)
    
    /**
     Called when the camera has outputted a video recording.
     
     - parameter url: The URL of the video file location.
     */
    func cameraDidFinishVideoRecording(atFileURL url: URL)
```

### Metadata Camera
```swift
    /**
     Called when there was a successful metadata scan for the specified metadata types.
     
     - parameter metadata: An array representing all the metadata that was detected.
     */
    func cameraDidScanMetadataInfo(metadata: [MetadataScanOutput])
```

### Requirements
- iOS 15.0+
- Swift 5.5+

### Installation

#### Swift Package Manager

- File > Swift Packages > Add Package Dependency
- Add `https://github.com/andreilob/CameraKage.git`
- Select "Up to Next Major" with "2.0.0"

### Development

Any contribution is welcome but before any pull request, please open a discussion first.

### Contact

For any contact you can find me on [Linkedin](https://www.linkedin.com/in/alobont/). If you find an issue, [open a ticket](https://github.com/andreilob/CameraKage/issues/new).
