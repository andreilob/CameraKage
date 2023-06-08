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

- [x] Fully customizable camera view.
- [x] Premission handling.
- [x] Delegate notifications.
- [x] Photo and video capture.
- [x] Camera flipping.
- [x] Adjustments for exposure and focus of the camera.
- [x] Capture session error and interruptions notifiers.

### CameraKage Setup

Start setting up CameraKage by importing the package and creating a view instance, either from interface builder or via code.

```swift
import CameraKage

let cameraView = CameraKage()
// Add the camera to your view and adjust the layout as you want.
```
After that, the embeding ViewController should be registered as a delegate in order to receive the wanted events from the camera via the CameraKageDelegate protocol.

```swift
cameraView.registerDelegate(self)
```
To startup the camera session, just call the startCameraSession method of the cameraView and provide the settings desired for the camera.

```swift
// An example of camera settings when starting the camera session.
cameraView.startCameraSession(with: CameraComponentParsedOptions([
            .deviceType(.builtInDualWideCamera),
            .devicePosition(.back),
            .maxVideoDuration(CMTime(seconds: 15, preferredTimescale: .max)),
            .photoQualityPrioritizationMode(.quality),
            .pinchToZoomEnabled(true),
            .videoStabilizationMode(.auto),
            .cameraOrientation(.portrait)
]))
```
With these steps you should have you camera up an running, what's left is just to call the capturePhoto or startVideoRecording methods.

### CameraKage Delegate

CameraKage provides a handful of useful notifications regarding the camera and the on-going camera session:

```swift
/**
     Called when the camera has outputted a photo.
     
     - parameter camera: The camera composer which is sending the event.
     - parameter data: The data representation of the photo.
     */
    func camera(_ camera: CameraKage, didOutputPhotoWithData data: Data)
    
    /**
     Called when the camera has started a video recording.
     
     - parameter camera: The camera composer which is sending the event.
     - parameter url: The file location where the video will be stored when recording ends.
     */
    func camera(_ camera: CameraKage, didStartRecordingVideoAtFileURL url: URL)
    
    /**
     Called when the camera has outputted a video recording.
     
     - parameter camera: The camera composer which is sending the event.
     - parameter url: The file location where the video is stored.
     */
    func camera(_ camera: CameraKage, didOutputVideoAtFileURL url: URL)
    
    /**
     Called when a pinch to zoom action happened on the camera component.
     
     - parameter camera: The camera composer which is sending the event.
     - parameter scale: The current zoom scale reported by the pinch gesture.
     - parameter maxScale: The maximum zoom scale of the camera.
     */
    func camera(_ camera: CameraKage, didZoomAtScale scale: CGFloat, outOfMaximumScale maxScale: CGFloat)
    
    /**
     Called when the camera composer encountered an error. Could be an output, camera or a session related error.
     
     - parameter camera: The camera composer which is sending the event.
     - parameter error: The error that was encountered.
     */
    func camera(_ camera: CameraKage, didEncounterError error: CameraError)
    
    /**
     Called when the camera session was interrupted. This can happen from various reason but most common
     ones would be phone calls while using the camera, other apps taking control over the
     phone camera or app moving to background.
     
     - parameter camera: The camera composer which is sending the event.
     - parameter reason: The reason for the session interruption.
     
     - important: When this is called, the camera will freezee so some UI overlay might be necessary on the client side.
     */
    func camera(_ camera: CameraKage, sessionWasInterrupted reason: SessionInterruptionReason)
    
    /**
     Called when the camera session interruption has ended. When this is called the camera will resume working.
     
     - parameter camera: The camera composer which is sending the event.
     */
    func cameraSessionInterruptionEnded(_ camera: CameraKage)
    
    /**
     Called when the camera session was started and the actual camera will be visible on screen.
     
     - parameter camera: The camera composer which is sending the event.
     */
    func cameraSessionDidStart(_ camera: CameraKage)
    
    /**
     Called when the camera session has stopped.
     
     - parameter camera: The camera composer which is sending the event.
     */
    func cameraSessionDidStop(_ camera: CameraKage)
    
    /**
     Posted when the instance of AVCaptureDevice has detected a substantial change to the video subject area.
     This notification is only sent if you first set monitorSubjectAreaChange to `true` in the `focus()` camera method.
     
     - parameter camera: The camera composer which is sending the event.
     */
    func cameraDeviceDidChangeSubjectArea(_ camera: CameraKage)
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
