//
//  CameraDevice+AVFoundation.swift
//  
//
//  Created by Lobont Andrei on 05.06.2023.
//

import AVFoundation

extension CameraDevice {
    var avDevicePosition: AVCaptureDevice.Position { self == .frontCamera ? .front : .back }
    
    var avDeviceType: AVCaptureDevice.DeviceType {
        switch self {
        case .frontCamera: return .builtInWideAngleCamera
        case .backWideCamera: return .builtInWideAngleCamera
        case .backTelephotoCamera: return .builtInTelephotoCamera
        case .backUltraWideCamera: return .builtInUltraWideCamera
        case .backDualCamera: return .builtInDualCamera
        case .backWideDualCamera: return .builtInDualWideCamera
        case .backTripleCamera: return .builtInTripleCamera
        }
    }
    
    static var availableDevices: [CameraDevice] {
        var devices: [CameraDevice] = []
        let avBackDevices = AVCaptureDevice.DiscoverySession(deviceTypes: [
            AVCaptureDevice.DeviceType.builtInWideAngleCamera,
            AVCaptureDevice.DeviceType.builtInUltraWideCamera,
            AVCaptureDevice.DeviceType.builtInTelephotoCamera,
            AVCaptureDevice.DeviceType.builtInDualCamera,
            AVCaptureDevice.DeviceType.builtInDualWideCamera,
            AVCaptureDevice.DeviceType.builtInTripleCamera,
        ],
                                                         mediaType: .video,
                                                         position: .back)
        avBackDevices.devices.forEach { device in
            switch device.deviceType {
            case .builtInWideAngleCamera: devices.append(.backWideCamera)
            case .builtInUltraWideCamera: devices.append(.backUltraWideCamera)
            case .builtInTelephotoCamera: devices.append(.backTelephotoCamera)
            case .builtInDualCamera: devices.append(.backDualCamera)
            case .builtInDualWideCamera: devices.append(.backWideDualCamera)
            case .builtInTripleCamera: devices.append(.backTripleCamera)
            default: break // Not using other device types
            }
        }
        
        let avFrontDevices = AVCaptureDevice.DiscoverySession(deviceTypes: [
            AVCaptureDevice.DeviceType.builtInWideAngleCamera
        ],
                                                              mediaType: .video,
                                                              position: .front)
        avFrontDevices.devices.forEach { device in
            switch device.deviceType {
            case .builtInWideAngleCamera: devices.append(.frontCamera)
            default: break // Not using other device types
            }
        }
        
        return devices
    }
}
