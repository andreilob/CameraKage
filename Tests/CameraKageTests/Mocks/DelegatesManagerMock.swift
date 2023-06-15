//
//  DelegatesManagerMock.swift
//  
//
//  Created by Lobont Andrei on 15.06.2023.
//

import Foundation
@testable import CameraKage

class DelegatesManagerMock: DelegatesManagerProtocol {
    var delegates: NSHashTable<AnyObject> = NSHashTable.weakObjects()
    
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
