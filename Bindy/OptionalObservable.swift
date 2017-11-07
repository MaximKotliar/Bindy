//
//  OptionalObservable.swift
//  Bindy
//
//  Created by Maxim Kotliar on 10/31/17.
//  Copyright © 2017 Maxim Kotliar. All rights reserved.
//
import Foundation

public final class OptionalObservable<T: Equatable>: ObservableValueHolder<Optional<T>> {

    public override var value: T? {
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
}
