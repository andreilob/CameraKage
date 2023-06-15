//
//  SessionComposer.swift
//  CameraKage
//
//  Created by Lobont Andrei on 26.05.2023.
//

import AVFoundation

final class SessionComposer {
    private let session: CaptureSession
    
    init(session: CaptureSession = CaptureSession()) {
        self.session = session
    }
    
    func createCameraView(options: CameraComponentParsedOptions) -> Result<CameraView, CameraError> {
        let videoInputResult = createVideoInput(options: options)
        switch videoInputResult {
        case .success(let videoInput):
            let audioInputResult = createAudioInput(options: options)
            switch audioInputResult {
            case .success(let audioInput):
                let videoLayerResult = createVideoPreviewLayer(options: options, videoDevice: videoInput)
                switch videoLayerResult {
                case .success(let videoLayer):
                    let cameraResult = createCamera(options: options,
                                                    videoInput: videoInput,
                                                    audioInput: audioInput,
                                                    videoLayer: videoLayer)
                    switch cameraResult {
                    case .success(let camera):
                        return .success(CameraView(camera: camera))
                    case .failure(let error):
                        return .failure(error)
                    }
                case .failure(let error):
                    return .failure(error)
                }
            case .failure(let error):
                return .failure(error)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func createPhotoCameraView(options: CameraComponentParsedOptions) -> Result<PhotoCameraView, CameraError> {
        let videoInputResult = createVideoInput(options: options)
        switch videoInputResult {
        case .success(let videoInput):
                let videoLayerResult = createVideoPreviewLayer(options: options, videoDevice: videoInput)
                switch videoLayerResult {
                case .success(let videoLayer):
                    let photoCameraResult = createPhotoCamera(options: options,
                                                              videoInput: videoInput,
                                                              videoLayer: videoLayer)
                    switch photoCameraResult {
                    case .success(let photoCamera):
                        return .success(PhotoCameraView(photoCamera: photoCamera))
                    case .failure(let error):
                        return .failure(error)
                    }
            case .failure(let error):
                return .failure(error)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func createVideoCameraView(options: CameraComponentParsedOptions) -> Result<VideoCameraView, CameraError> {
        let videoInputResult = createVideoInput(options: options)
        switch videoInputResult {
        case .success(let videoInput):
            let audioInputResult = createAudioInput(options: options)
            switch audioInputResult {
            case .success(let audioInput):
                let videoLayerResult = createVideoPreviewLayer(options: options, videoDevice: videoInput)
                switch videoLayerResult {
                case .success(let videoLayer):
                    let videoCameraResult = createVideoCamera(options: options,
                                                              videoInput: videoInput,
                                                              audioInput: audioInput,
                                                              videoLayer: videoLayer)
                    switch videoCameraResult {
                    case .success(let videoCamera):
                        return .success(VideoCameraView(videoCamera: videoCamera))
                    case .failure(let error):
                        return .failure(error)
                    }
                case .failure(let error):
                    return .failure(error)
                }
            case .failure(let error):
                return .failure(error)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
    
    private func createCamera(options: CameraComponentParsedOptions,
                              videoInput: VideoCaptureDevice,
                              audioInput: AudioCaptureDevice,
                              videoLayer: PreviewLayer) -> Result<Camera, CameraError> {
        let movieCapturerResult = createMovieCapturer(options: options,
                                                      videoDevice: videoInput,
                                                      audioDevice: audioInput)
        switch movieCapturerResult {
        case .success(let movieCapturer):
            let photoCapturerResult = createPhotoCapturer(options: options, videoDevice: videoInput)
            switch photoCapturerResult {
            case .success(let photoCapturer):
                return .success(Camera(session: session,
                                       videoInput: videoInput,
                                       videoLayer: videoLayer,
                                       photoCapturer: photoCapturer,
                                       movieCapturer: movieCapturer,
                                       options: options))
            case .failure(let error):
                return .failure(error)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
    
    private func createVideoCamera(options: CameraComponentParsedOptions,
                                   videoInput: VideoCaptureDevice,
                                   audioInput: AudioCaptureDevice,
                                   videoLayer: PreviewLayer) -> Result<VideoCamera, CameraError> {
        let movieCapturerResult = createMovieCapturer(options: options,
                                                      videoDevice: videoInput,
                                                      audioDevice: audioInput)
        switch movieCapturerResult {
        case .success(let movieCapturer):
            return .success(VideoCamera(session: session,
                                        videoInput: videoInput,
                                        videoLayer: videoLayer,
                                        movieCapturer: movieCapturer,
                                        options: options))
        case .failure(let error):
            return .failure(error)
        }
    }
    
    private func createPhotoCamera(options: CameraComponentParsedOptions,
                                   videoInput: VideoCaptureDevice,
                                   videoLayer: PreviewLayer) -> Result<PhotoCamera, CameraError> {
        let photoCapturerResult = createPhotoCapturer(options: options, videoDevice: videoInput)
        switch photoCapturerResult {
        case .success(let photoCapturer):
            return .success(PhotoCamera(session: session,
                                        videoInput: videoInput,
                                        videoLayer: videoLayer,
                                        photoCapturer: photoCapturer,
                                        options: options))
        case .failure(let error):
            return .failure(error)
        }
    }
    
    private func createBaseCamera(options: CameraComponentParsedOptions) -> Result<BaseCamera, CameraError> {
        let videoInputResult = createVideoInput(options: options)
        switch videoInputResult {
        case .success(let videoInput):
            let videoLayerResult = createVideoPreviewLayer(options: options, videoDevice: videoInput)
            switch videoLayerResult {
            case .success(let videoLayer):
                return .success(BaseCamera(session: session,
                                           videoInput: videoInput,
                                           videoLayer: videoLayer,
                                           options: options))
            case .failure(let error):
                return .failure(error)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
    
    private func createVideoInput(options: CameraComponentParsedOptions) -> Result<VideoCaptureDevice, CameraError> {
        guard let videoInput = VideoCaptureDevice(session: session,
                                                  options: options) else {
            return .failure(.cameraComponentError(reason: .failedToConfigureVideoDevice))
        }
        return .success(videoInput)
    }
    
    private func createAudioInput(options: CameraComponentParsedOptions) -> Result<AudioCaptureDevice, CameraError> {
        guard let audioInput = AudioCaptureDevice(session: session,
                                                  options: options) else {
            return .failure(.cameraComponentError(reason: .failedToConfigureAudioDevice))
        }
        return .success(audioInput)
    }
    
    private func createPhotoCapturer(options: CameraComponentParsedOptions,
                                     videoDevice: VideoCaptureDevice) -> Result<PhotoOutput, CameraError> {
        guard let photoCapturer = PhotoOutput(session: session,
                                              options: options,
                                              videoDevice: videoDevice) else {
            return .failure(.cameraComponentError(reason: .failedToAddPhotoOutput))
        }
        return .success(photoCapturer)
    }
    
    private func createMovieCapturer(options: CameraComponentParsedOptions,
                                     videoDevice: VideoCaptureDevice,
                                     audioDevice: AudioCaptureDevice) -> Result<MovieOutput, CameraError> {
        guard let movieCapturer = MovieOutput(forSession: session,
                                              andOptions: options,
                                              videoDevice: videoDevice,
                                              audioDevice: audioDevice) else {
            return .failure(.cameraComponentError(reason: .failedToAddMovieOutput))
        }
        return .success(movieCapturer)
    }
    
    private func createVideoPreviewLayer(options: CameraComponentParsedOptions,
                                         videoDevice: VideoCaptureDevice) -> Result<PreviewLayer, CameraError> {
        guard let videoLayer = PreviewLayer(session: session,
                                            options: options,
                                            videoDevice: videoDevice) else {
            return .failure(.cameraComponentError(reason: .failedToAddPreviewLayer))
        }
        return .success(videoLayer)
    }
}
