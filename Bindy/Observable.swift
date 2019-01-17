//
//  Observable.swift
//  Bindy
//
//  Created by Maxim Kotliar on 10/31/17.
//  Copyright © 2017 Maxim Kotliar. All rights reserved.
//

import Foundation

public final class Observable<T>: ObservableValueHolder<T> {

    let comparisonClosure: ((T, T) -> Bool)?

    public override var value: T {
        didSet {
            let isEqual = comparisonClosure?(oldValue, value) ?? false
            guard !isEqual else { return }
            fireBindings(with: value)
        }
    }

    public required init(_ value: T, options: [ObservableValueHolderOptionKey: Any]? = nil) {
        self.comparisonClosure = options.flatMap { $0[.comparisonClosure] as? (T, T) -> Bool }
        super.init(value, options: options)
    }

    public convenience init(_ value: T, comparison: ((T, T) -> Bool)?) {
        self.init(value, options: comparison.flatMap { [.comparisonClosure: $0] } )
    }
}

public extension Observable where T: Equatable {

    public convenience init(_ value: T) {
        self.init(value, comparison: ==)
    }
}

extension Observable {

    public func transform<U: Equatable>(_ transform: @escaping (T) -> U) -> Observable<U> {
        let transformedObserver = Observable<U>(transform(value), options: nil)
        observe(self) { [unowned self] (value) in
            transformedObserver.value = transform(self.value)
        }
        return transformedObserver
    }
}

public protocol ExtendableClass: class {}
extension NSObject: ExtendableClass {}

public extension ExtendableClass {
    public func attach<T>(to observable: Observable<T>, callback: @escaping (Self, T) -> Void) {
        observable.observe(self) { [unowned self] value in
            callback(self, value)
        }
    }
}

