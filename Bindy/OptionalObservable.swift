//
//  OptionalObservable.swift
//  Bindy
//
//  Created by Maxim Kotliar on 10/31/17.
//  Copyright © 2017 Maxim Kotliar. All rights reserved.
//
import Foundation

public final class OptionalObservable<T: Equatable>: ObservableValueHolder {

    public typealias ObservableType = T?
    public typealias ChangeType = T?

    var bindings = NSMapTable<AnyObject, Binding>.weakToStrongObjects()

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
            fireBindings(with: value)
        }
    }
    
    public init(_ value: T? = nil) {
        self.value = value
    }
}

extension OptionalObservable: Equatable {
    
    public static func == (lhs: OptionalObservable<T>,
                           rhs: OptionalObservable<T>) -> Bool {
        return lhs === rhs
    }
}
