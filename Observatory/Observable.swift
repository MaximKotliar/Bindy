//
//  Observable.swift
//  Observatory
//
//  Created by Maxim Kotliar on 10/31/17.
//  Copyright © 2017 Maxim Kotliar. All rights reserved.
//

import Foundation

public class Observable<T: Equatable> {
    
    class Bind {
        var actions: [(T) -> Void] = []
    }
    
    private var bindings = NSMapTable<AnyObject, Bind>.weakToStrongObjects()
    
    public var value: T {
        didSet {
            guard oldValue != self.value,
                let enumerator = self.bindings.objectEnumerator() else { return }
            enumerator.allObjects.forEach { bind in
                (bind as? Bind)?.actions.forEach { $0(self.value) }
            }
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
    public func observe(_ owner: AnyObject, callback: @escaping (T) -> Void) -> Self {
        callback(value)
        return bind(owner, callback: callback)
    }
    @discardableResult
    public func unbind(_ owner: AnyObject) -> Bool {
        let hasBinding = bindings.object(forKey: owner) != nil
        bindings.removeObject(forKey: owner)
        return hasBinding
    }
    
    public init(_ value: T) {
        self.value = value
    }
}

extension Observable: Equatable {
    public static func == (lhs: Observable, rhs: Observable) -> Bool {
        return lhs === rhs
    }
}

