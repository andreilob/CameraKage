//
//  UIImage+Resize.swift
//  
//
//  Created by Lobont Andrei on 05.07.2023.
//

import UIKit

extension UIImage {
    func resized(to newSize: CGSize) -> UIImage? {
        defer { UIGraphicsEndImageContext() }
        UIGraphicsBeginImageContextWithOptions(newSize, false, scale)
        draw(in: CGRect(x: 0.0,
                        y: 0.0,
                        width: newSize.width,
                        height: newSize.height))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
