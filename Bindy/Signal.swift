//
//  Signal.swift
//  Bindy
//
//  Created by Maxim Kotliar on 10/31/17.
//  Copyright © 2017 Maxim Kotliar. All rights reserved.
//
import Foundation

public class Signal<T> {
    
    class Bind {
        var actions: [(T) -> Void] = []
    }
    
    private var bindings = NSMapTable<AnyObject, Bind>.weakToStrongObjects()
    
    public func send(_ value: T) {
        guard let enumerator = self.bindings.objectEnumerator() else { return }
        enumerator.allObjects.forEach { bind in
            (bind as? Bind)?.actions.forEach { $0(value) }
        }
    }
    
    @discardableResult
    public func bind(_ owner: AnyObject, callback: @escaping (T) -> Void) -> Self {
        let bind = bindings.object(forKey: owner) ?? Bind()
        bind.actions.append(callback)
        bindings.setObject(bind, forKey: owner)
        return self
    }
 
    @discardableResult
    public func unbind(_ owner: AnyObject) -> Bool {
        let hasBinding = bindings.object(forKey: owner) != nil
        bindings.removeObject(forKey: owner)
        return hasBinding
    }
}

extension Signal: Equatable {
    public static func == (lhs: Signal, rhs: Signal) -> Bool {
        return lhs === rhs
    }
}
