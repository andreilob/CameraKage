//
//  MovieCapturer.swift
//  
//
//  Created by Lobont Andrei on 09.06.2023.
//

import Foundation

protocol MovieCapturer {
    var isRecording: Bool { get }
    var onMovieCaptureSuccess: ((URL) -> Void)? { get set }
    var onMovieCaptureStart: ((URL) -> Void)? { get set }
    var onMovieCaptureError: ((CameraError) -> Void)? { get set }
    
    func startMovieRecording()
    func stopMovieRecording()
    func handleFlip() throws
}
