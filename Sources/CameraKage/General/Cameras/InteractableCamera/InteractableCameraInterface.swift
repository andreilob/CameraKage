//
//  InteractableCameraInterface.swift
//  
//
//  Created by Lobont Andrei on 11.06.2023.
//

import Foundation

protocol InteractableCameraInterface: SessionCameraInterface {
    var isZoomAllowed: Bool { get }
    var maxZoomScale: CGFloat { get }
    
    func flipCamera() throws
    func focus(with focusMode: FocusMode,
               exposureMode: ExposureMode,
               at devicePoint: CGPoint,
               monitorSubjectAreaChange: Bool) throws
    func zoom(atScale scale: CGFloat) throws
    func minMaxZoom(_ factor: CGFloat) -> CGFloat
}
