//
//  OptionalObservable.swift
//  Observatory
//
//  Created by Maxim Kotliar on 10/31/17.
//  Copyright © 2017 Maxim Kotliar. All rights reserved.
//
import Foundation

public class OptionalObservable<T: Equatable> {
    
    class Bind {
        var actions: [Callback<T?>] = []
    }
    
    private var bindings = NSMapTable<AnyObject, Bind>.weakToStrongObjects()
    
    var bindingsCount: Int {
        return bindings.count
    }
    
    var value: T? {
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
    
    @discardableResult func unbind(_ owner: AnyObject) -> Bool {
        let hasBinding = bindings.object(forKey: owner) != nil
        bindings.removeObject(forKey: owner)
        return hasBinding
    }
    
    @discardableResult
    func bind(_ owner: AnyObject, callback: @escaping Callback<T?>) -> Self {
        let bind = bindings.object(forKey: owner) ?? Bind()
        bind.actions.append(callback)
        bindings.setObject(bind, forKey: owner)
        return self
    }
    
    @discardableResult
    func observe(_ owner: AnyObject, callback: @escaping Callback<T?>) -> Self {
        callback(value)
        return bind(owner, callback: callback)
    }
    
    init(_ value: T? = nil) {
        self.value = value
    }
}

extension OptionalObservable: Equatable {
    
    static func == (lhs: OptionalObservable<T>, rhs: OptionalObservable<T>) -> Bool {
        return lhs === rhs
    }
}
