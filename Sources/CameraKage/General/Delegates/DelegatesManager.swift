//
//  DelegatesManager.swift
//  
//
//  Created by Lobont Andrei on 29.05.2023.
//

import Foundation

protocol DelegatesManagerProtocol {
    var delegates: NSHashTable<AnyObject> { get }
    
    func registerDelegate(_ delegate: AnyObject)
    func unregisterDelegate(_ delegate: AnyObject)
    func invokeDelegates(_ execute: (AnyObject) -> Void)
}

final class DelegatesManager: DelegatesManagerProtocol {
    let delegates: NSHashTable<AnyObject> = NSHashTable.weakObjects()
    
    func registerDelegate(_ delegate: AnyObject) {
        delegates.add(delegate)
    }
    
    func unregisterDelegate(_ delegate: AnyObject) {
        delegates.remove(delegate)
    }
    
    func invokeDelegates(_ execute: (AnyObject) -> Void) {
        delegates.allObjects.forEach { delegate in
            execute(delegate)
        }
    }
}
