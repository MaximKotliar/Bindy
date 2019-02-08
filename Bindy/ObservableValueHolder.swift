//
//  ObservableValueHolder.swift
//  Bindy
//
//  Created by Maxim Kotliar on 11/6/17.
//  Copyright © 2017 Maxim Kotliar. All rights reserved.
//

import Foundation

public struct ObservableValueHolderOptionKey: Hashable, ExpressibleByStringLiteral {
    let key: String

    public init(stringLiteral value: String) {
        self.key = value
    }
}

public extension ObservableValueHolderOptionKey {
    public static let equalityClosure: ObservableValueHolderOptionKey = "equalityClosure"
}

public class ObservableValueHolder<T>: ObserveCapable<T> {

    open var value: T

    var options: [ObservableValueHolderOptionKey: Any]?

    @discardableResult
    public func observe(_ owner: AnyObject,
                        callback: @escaping (T) -> Void) -> Self {
        callback(value)
        return bind(owner, callback: callback)
    }

    @discardableResult
    public func bind(_ owner: AnyObject,
                     callbackWithOldValue callback: @escaping (T, T) -> Void) -> Self {
        let bind = bindings.object(forKey: owner) ?? Binding()
        bind.oldValueNewValueActions.append(callback)
        bindings.setObject(bind, forKey: owner)
        return self
    }

    @discardableResult
    public func bindToOldValue(_ owner: AnyObject,
                     callback: @escaping (T) -> Void) -> Self {
        let bind = bindings.object(forKey: owner) ?? Binding()
        bind.oldValueActions.append(callback)
        bindings.setObject(bind, forKey: owner)
        return self
    }

    @discardableResult
    public func observe(_ owner: AnyObject,
                        callbackWithOldValue callback: @escaping (T, T) -> Void) -> Self {
        callback(value, value)
        return bind(owner, callbackWithOldValue: callback)
    }

    public required init(_ value: T, options: [ObservableValueHolderOptionKey: Any]?) {
        self.value = value
        self.options = options
    }
}

public extension ObservableValueHolder {

    public func combined<U, R>(with other: Observable<U>,
                             transform: @escaping (T, U) -> R) -> Observable<R> {
        let combined = transform(self.value, other.value)
        let observable = Observable(combined, options: options)
        self.bind(observable, callback: { (value) in
            observable.value = transform(self.value, other.value)
        })
        other.bind(observable, callback: { (value) in
            observable.value = transform(self.value, other.value)
        })
        return observable
    }

    public func combined<U, R>(with other: ObservableArray<U>,
                             transform: @escaping (T, [U]) -> [R]) -> ObservableArray<R> {
        let combined = transform(self.value, other.value)
        let observable = ObservableArray(combined, options: options)
        self.bind(observable, callback: { (value) in
            observable.value = transform(self.value, other.value)
        })
        other.bind(observable, callback: { (value) in
            observable.value = transform(self.value, other.value)
        })
        return observable
    }
}

public extension ObservableArray {

    public func combinedArray<R>(with other: Observable<T>, transform: @escaping ([Element], T) -> R) -> Observable<R> {
        let combined = transform(self.value, other.value)
        let observable = Observable(combined, options: options)
        self.bind(observable, callback: { (value) in
            observable.value = transform(self.value, other.value)
        })
        other.bind(observable, callback: { (value) in
            observable.value = transform(self.value, other.value)
        })
        return observable
    }
}
