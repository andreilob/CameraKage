//
//  MetadataType.swift
//  
//
//  Created by Lobont Andrei on 19.06.2023.
//

import Foundation

public enum MetadataType {
    /// Used to detect UPC-E codes.
    case upce

    /// Used to detect Code 39 codes.
    case code39

    /// Used to detect Code 39 mod 43 codes.
    case code39Mod43

    /// Used to detect EAN-13(including UPC-A) codes.
    case ean13

    /// Used to detect EAN-8 codes.
    case ean8

    /// Used to detect Code 93 codes.
    case code93

    /// Used to detect Code 128 codes.
    case code128

    /// Used to detect PDF417 codes.
    case pdf417

    /// Used to detect QR codes.
    case qr

    /// Used to detect Aztec codes.
    case aztec

    /// Used to detect Interleaved 2 of 5 codes.
    case interleaved2of5

    /// Used to detect ITF14 codes.
    case itf14

    /// Used to detect DataMatrix codes.
    case dataMatrix
}
