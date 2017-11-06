//
//  Signal.swift
//  Bindy
//
//  Created by Maxim Kotliar on 10/31/17.
//  Copyright © 2017 Maxim Kotliar. All rights reserved.
//
import Foundation

final public class Signal<T>: ObserveCapable {

    public typealias ObservableType = T
    public typealias ChangeType = T

    public init() {}

    var bindings = NSMapTable<AnyObject, Binding>.weakToStrongObjects()
    
    public func send(_ value: T) {
        fireBindings(with: value)
    }
}

extension Signal: Equatable {
    public static func == (lhs: Signal, rhs: Signal) -> Bool {
        return lhs === rhs
    }
}
