//
//  MovieOutputMock.swift
//  
//
//  Created by Lobont Andrei on 19.06.2023.
//

import Foundation
@testable import CameraKage

class MovieOutputMock: MovieCapturer {
    var isRecording: Bool = false
    
    var onMovieCaptureSuccess: ((URL) -> Void)?
    var onMovieCaptureStart: ((URL) -> Void)?
    var onMovieCaptureError: ((CameraError) -> Void)?
    
    func startMovieRecording() {
        isRecording = true
    }
    
    func stopMovieRecording() {
        isRecording = false
    }
    
    func handleFlip() throws {}
}
