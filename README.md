<p align="center">
<img src="https://raw.githubusercontent.com/andreilob/CameraKage/main/images/logo.png" alt="CameraKage" title="CameraKage" width="600"/>
</p>

<p align="center">
<a href="https://swift.org/package-manager/"><img src="https://img.shields.io/badge/SPM-supported-DE5C43.svg?style=flat"></a>
<a href="https://raw.githubusercontent.com/andreilob/CameraKage/main/LICENSE"><img src="https://img.shields.io/badge/license-MIT-black"></a>
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

CameraKage provides a bunch of handy notifiers. Some important ones would be:

```swift
// Used to receive the result of a photo capture.
func camera(_ camera: CameraKage, didOutputPhotoWithData data: Data)

// Used to receive the result of a video capture.
func camera(_ camera: CameraKage, didOutputVideoAtFileURL url: URL)

// Used to handle camera related errors.
func camera(_ camera: CameraKage, didEncounterError error: CameraError)

// Used to handle sessions interruptions. (ex. phone calls, app going into the background, camera taken by another app, etc.)
func camera(_ camera: CameraKage, sessionWasInterrupted reason: SessionInterruptionReason)
```

### Requirements
- iOS 15.0+
- Swift 5.8+

### Installation

#### Swift Package Manager

- File > Swift Packages > Add Package Dependency
- Add `https://github.com/andreilob/CameraKage.git`
- Select "Up to Next Major" with "1.0.0"

### Development

Any contribution is welcome but before any pull request, please open a discussion first.

### Contact

For any contact you can find me on [Linkedin](https://www.linkedin.com/in/alobont/). If you find an issue, [open a ticket](https://github.com/andreilob/CameraKage/issues/new).
