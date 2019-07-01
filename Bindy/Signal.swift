//
//  Signal.swift
//  Bindy
//
//  Created by Maxim Kotliar on 10/31/17.
//  Copyright © 2017 Maxim Kotliar. All rights reserved.
//
import Foundation

final public class Signal<T>: ObserveCapable<T> {
    public func send(_ value: T) {
        fireBindings(with: .newValue(value))
    }
}

public extension Signal where T == Void {
    func send() {
        send(())
    }
}
