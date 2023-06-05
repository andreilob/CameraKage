//
//  DelegatesManager.swift
//  
//
//  Created by Lobont Andrei on 29.05.2023.
//

import Foundation

protocol DelegatesManagerProtocol {
    var delegates: NSHashTable<AnyObject> { get }
    
    func registerDelegate(_ delegate: CameraKageDelegate)
    func unregisterDelegate(_ delegate: CameraKageDelegate)
    func invokeDelegates(_ execute: (CameraKageDelegate) -> Void)
}

final class DelegatesManager: DelegatesManagerProtocol {
    let delegates: NSHashTable<AnyObject> = NSHashTable.weakObjects()
    
    func registerDelegate(_ delegate: CameraKageDelegate) {
        delegates.add(delegate as AnyObject)
    }
    
    func unregisterDelegate(_ delegate: CameraKageDelegate) {
        delegates.remove(delegate as AnyObject)
    }
    
    func invokeDelegates(_ execute: (CameraKageDelegate) -> Void) {
        delegates.allObjects.forEach { delegate in
            guard let delegate = delegate as? CameraKageDelegate else { return }
            execute(delegate)
        }
    }
}
