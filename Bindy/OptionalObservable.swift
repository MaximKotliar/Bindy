//
//  OptionalObservable.swift
//  Bindy
//
//  Created by Maxim Kotliar on 10/31/17.
//  Copyright © 2017 Maxim Kotliar. All rights reserved.
//
import Foundation

public class OptionalObservable<T: Equatable> {
    
    class Bind {
        var actions: [(T?) -> Void] = []
    }
    
    private var bindings = NSMapTable<AnyObject, Bind>.weakToStrongObjects()
    
    public var bindingsCount: Int {
        return bindings.count
    }
    
    public var value: T? {
        didSet {
            
            // We don't need to trigger callbacks if both are equal or nil
            switch (oldValue, value) {
            case (.some(let unwrappedOldValue), .some(let unwrappedValue)):
                guard unwrappedOldValue != unwrappedValue else { return }
            case  (.none, .none):
                return
            default:
                break
            }
            
            guard let enumerator = bindings.objectEnumerator() else { return }
            
            enumerator.allObjects.forEach { bind in
                (bind as? Bind)?.actions.forEach { $0(value) }
            }
        }
    }
    
    @discardableResult
    public func unbind(_ owner: AnyObject) -> Bool {
        let hasBinding = bindings.object(forKey: owner) != nil
        bindings.removeObject(forKey: owner)
        return hasBinding
    }
    
    @discardableResult
    public func bind(_ owner: AnyObject, callback: @escaping (T?) -> Void) -> Self {
        let bind = bindings.object(forKey: owner) ?? Bind()
        bind.actions.append(callback)
        bindings.setObject(bind, forKey: owner)
        return self
    }
    
    @discardableResult
    public func observe(_ owner: AnyObject, callback: @escaping (T?) -> Void) -> Self {
        callback(value)
        return bind(owner, callback: callback)
    }
    
    public init(_ value: T? = nil) {
        self.value = value
    }
}

extension OptionalObservable: Equatable {
    
    public static func == (lhs: OptionalObservable<T>, rhs: OptionalObservable<T>) -> Bool {
        return lhs === rhs
    }
}
