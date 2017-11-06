//
//  Signal.swift
//  Bindy
//
//  Created by Maxim Kotliar on 10/31/17.
//  Copyright © 2017 Maxim Kotliar. All rights reserved.
//
import Foundation

final public class Signal<T>: ObserveCapable<T, T> {

    public func send(_ value: T) {
        fireBindings(with: value)
    }
}
