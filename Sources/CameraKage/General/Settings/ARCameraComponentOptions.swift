//
//  ARCameraComponentOptions.swift
//  
//
//  Created by Lobont Andrei on 22.06.2023.
//

import Foundation

public typealias ARCameraComponentOptions = [ARCameraComponentOptionItem]

public enum ARCameraComponentOptionItem {
    /// Specifies whether the receiver should automatically light up scenes that have no light source.
    /// When enabled, a diffuse light is automatically added and placed while rendering scenes that have no light or only ambient lights.
    /// Default is `true`.
    case autoenablesDefaultLighting(Bool)
    
    /// Specifies whether the receiver should jitter the rendered scene to reduce aliasing artifacts.
    /// Default is `false`.
    case isJitteringEnabled(Bool)
    
    /// Specifies whether the receiver should reduce aliasing artifacts in real time based on temporal coherency.
    /// Default is `false`.
    case isTemporalAntialiasingEnabled(Bool)
    
    /// The queue that will be used to notify delegate events.
    /// Default is `.main`.
    case delegateQueue(DispatchQueue)
}

/// Options used to configure a camera view.
public class ARCameraComponentParsedOptions {
    public var autoenablesDefaultLighting = true
    public var isJitteringEnabled = false
    public var isTemporalAntialiasingEnabled = false
    public var delegateQeueue: DispatchQueue = .main
    
    public init(_ options: ARCameraComponentOptions?) {
        guard let options else { return }
        options.forEach {
            switch $0 {
            case .autoenablesDefaultLighting(let autoenablesDefaultLighting):
                self.autoenablesDefaultLighting = autoenablesDefaultLighting
            case .isJitteringEnabled(let isJitteringEnabled):
                self.isJitteringEnabled = isJitteringEnabled
            case .isTemporalAntialiasingEnabled(let isTemporalAntialiasingEnabled):
                self.isTemporalAntialiasingEnabled = isTemporalAntialiasingEnabled
            case .delegateQueue(let delegateQueue):
                self.delegateQeueue = delegateQueue
            }
        }
    }
}
