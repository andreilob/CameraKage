//
//  UIImage+PixelBuffer.swift
//  
//
//  Created by Lobont Andrei on 20.06.2023.
//

import UIKit

extension UIImage {
    func pixelBuffer() -> CVPixelBuffer? {
        var buffer: CVPixelBuffer! = nil
        let options = [kCVPixelBufferCGImageCompatibilityKey as String: true,
                       kCVPixelBufferCGBitmapContextCompatibilityKey as String: true]
        let width = size.width
        let height = size.height
        let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                         Int(width),
                                         Int(height),
                                         kCVPixelFormatType_32ARGB,
                                         options as CFDictionary?,
                                         &buffer)
        guard status == kCVReturnSuccess, buffer != nil else { return nil }
        CVPixelBufferLockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: 0))
        guard let context = CGContext(data: CVPixelBufferGetBaseAddress(buffer),
                                      width: Int(width),
                                      height: Int(height),
                                      bitsPerComponent: 8,
                                      bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
                                      space: CGColorSpaceCreateDeviceRGB(),
                                      bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue) else { return nil }
        
        var transform = CGAffineTransform.identity
        transform = transform.translatedBy(x: width / 2, y: height / 2)
        switch imageOrientation {
        case .left:
            transform = transform.rotated(by: .pi / 2)
            transform = transform.scaledBy(x: height / width, y: width / height)
        case .down:
            transform = transform.rotated(by: .pi)
        case .right:
            transform = transform.rotated(by: -.pi / 2)
            transform = transform.scaledBy(x: height / width, y: width / height)
        default:
            break
        }
        transform = transform.translatedBy(x: -width / 2, y: -height / 2)
        context.concatenate(transform)
        
        guard let cgImage = cgImage else { return nil }
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        CVPixelBufferUnlockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: 0))
        return buffer
    }
}
