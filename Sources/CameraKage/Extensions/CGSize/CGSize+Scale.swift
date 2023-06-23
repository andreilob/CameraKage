//
//  CGSize+Scale.swift
//  
//
//  Created by Lobont Andrei on 22.06.2023.
//

import Foundation

extension CGSize {
    func scaled(by factor: CGFloat) -> CGSize {
        CGSize(width: width * factor, height: height * factor)
    }
    
    func scaled(by size: CGSize) -> CGSize {
        CGSize(width: width * size.width, height: height * size.height)
    }
    
    func scale(with ratio: CGFloat) -> CGSize {
        CGSize(width: max(1, floor(width * ratio)), height: max(1, floor(height * ratio)))
    }
    
    func aspectFit(to boundingSize: CGSize) -> CGSize {
        var result = boundingSize
        
        let widthFactor = boundingSize.width / width
        let heightFactor = boundingSize.height / height
        
        if heightFactor < widthFactor {
            result.width = boundingSize.height / height * width
        } else if widthFactor < heightFactor {
            result.height = boundingSize.width / width * height
        }
        
        return result
    }
    
    func aspectFill(to boundingSize: CGSize) -> CGSize {
        var result = boundingSize
        
        let widthFactor = boundingSize.width / width
        let heightFactor = boundingSize.height / height
        
        if widthFactor < heightFactor {
            result.width = boundingSize.height / height * width
        } else if heightFactor < widthFactor {
            result.height = boundingSize.width / width * height
        }
        
        return result
    }
    
    func aspectFill(to frameRect: CGRect) -> CGRect {
        let aspectFillSize = aspectFill(to: frameRect.size)
        let result = CGRect(origin: CGPoint(x: frameRect.minX - (aspectFillSize.width - frameRect.width) / 2.0,
                                            y: frameRect.minX - (aspectFillSize.height - frameRect.height) / 2.0),
                            size: aspectFillSize)
        return result
    }
    
    func aspectFit(to frameRect: CGRect) -> CGRect {
        let aspectFitSize = aspectFit(to: frameRect.size)
        let result = CGRect(origin: CGPoint(x: frameRect.minX + (frameRect.width - aspectFitSize.width) / 2.0,
                                            y: frameRect.minX + (frameRect.height - aspectFitSize.height) / 2.0),
                            size: aspectFitSize)
        return result
    }
    
    func rounded() -> CGSize {
        CGSize(width: width.rounded(), height: height.rounded())
    }
}
