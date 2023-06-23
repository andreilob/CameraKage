//
//  Session.swift
//  
//
//  Created by Lobont Andrei on 09.06.2023.
//

import Foundation

protocol Session {
    var isRunning: Bool { get }
    var delegate: SessionDelegate? { get set }
    
    func startSession()
    func stopSession()
    func beginConfiguration()
    func commitConfiguration()
    func addObservers()
    func removeObservers()
}
