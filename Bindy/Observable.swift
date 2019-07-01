//
//  Observable.swift
//  Bindy
//
//  Created by Maxim Kotliar on 10/31/17.
//  Copyright © 2017 Maxim Kotliar. All rights reserved.
//

import Foundation

public final class Observable<T>: ObservableValueHolder<T> {

    let equalityClosure: ((T, T) -> Bool)?

    public override var value: T {
        didSet {
            let isEqual = equalityClosure?(oldValue, value) ?? false
            guard !isEqual else { return }
            fireBindings(with: .oldValueNewValue(oldValue, value))
        }
    }

    public required init(_ value: T, options: [ObservableValueHolderOptionKey: Any]? = nil) {
        self.equalityClosure = options.flatMap { $0[.equalityClosure] as? (T, T) -> Bool }
        super.init(value, options: options)
    }

    public convenience init(_ value: T, equalityCheck: ((T, T) -> Bool)?) {
        self.init(value, options: equalityCheck.flatMap { [.equalityClosure: $0] } )
    }
}

extension Observable {

    public func transform<U>(_ transform: @escaping (T) -> U, options: [ObservableValueHolderOptionKey: Any]? = nil) -> Observable<U> {
        let transformedObserver = Observable<U>(transform(value), options: options)
        observe(self) { [unowned self] (value) in
            transformedObserver.value = transform(self.value)
        }
        return transformedObserver
    }

    public func transform<U>(_ transform: @escaping (T) -> U, equalityCheck: ((U, U) -> Bool)?) -> Observable<U> {
        return self.transform(transform, options: equalityCheck.flatMap { [.equalityClosure: $0] })
    }

    public func transform<U: Equatable>(_ transform: @escaping (T) -> U) -> Observable<U> {
        return self.transform(transform, equalityCheck: ==)
    }
}

public extension Observable where T: Equatable {

    convenience init(_ value: T) {
        self.init(value, equalityCheck: ==)
    }
}


public protocol ExtendableClass: class {}
extension NSObject: ExtendableClass {}

public extension ExtendableClass {
    func attach<T>(to observable: Observable<T>, callback: @escaping (Self, T) -> Void) {
        observable.observe(self) { [unowned self] value in
            callback(self, value)
        }
    }
}

