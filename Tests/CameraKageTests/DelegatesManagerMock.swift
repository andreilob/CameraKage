//
//  DelegatesManagerMock.swift
//  
//
//  Created by Lobont Andrei on 29.05.2023.
//

import Foundation
@testable import CameraKage

final class DelegatesManagerMock: DelegatesManagerProtocol {
    var delegates: NSHashTable<AnyObject> = NSHashTable.weakObjects()
    
    func registerDelegate(_ delegate: CameraKageDelegate) {
        delegates.add(delegate as AnyObject)
    }
    
    func unregisterDelegate(_ delegate: CameraKageDelegate) {
        delegates.remove(delegate as AnyObject)
    }
    
    func invokeDelegates(_ execute: (CameraKageDelegate) -> Void) {
        delegates.allObjects.forEach { delegate in
            guard let delegate = delegate as? CameraKageDelegateMock else { return }
            delegate.invoked = true
            execute(delegate)
        }
    }
}
