//
//  VideoInput.swift
//  
//
//  Created by Lobont Andrei on 09.06.2023.
//

import Foundation

protocol VideoInput {
    var onVideoDeviceError: ((CameraError) -> Void)? { get set }
    
    func flip() throws
    func focus(focusMode: FocusMode, exposureMode: ExposureMode, point: CGPoint, monitorSubjectAreaChange: Bool) throws
    func zoom(atScale: CGFloat) throws
    func minMaxZoom(_ factor: CGFloat, options: CameraComponentParsedOptions) -> CGFloat
    func configureFlash(_ flashMode: FlashMode) throws
    func addObservers()
    func removeObservers()
}
