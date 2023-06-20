//
//  MetadataCapturer.swift
//  
//
//  Created by Lobont Andrei on 15.06.2023.
//

import Foundation

protocol MetadataCapturer {
    var onSuccessfullMetadataScan: (([MetadataScanOutput]) -> Void)? { get set }
}
