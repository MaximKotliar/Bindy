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
    static let equalityClosure: ObservableValueHolderOptionKey = "equalityClosure"
}

#if swift(>=5.1)
@dynamicMemberLookup
public class ObservableValueHolder<ObservableType>: ObserveCapable<ObservableType> {
    open var value: ObservableType
    var options: [ObservableValueHolderOptionKey: Any]?

    public required init(_ value: ObservableType, options: [ObservableValueHolderOptionKey: Any]?) {
        self.value = value
        self.options = options
    }

    public subscript<T>(dynamicMember keyPath: KeyPath<ObservableType, T>) -> T {
        return value[keyPath: keyPath]
    }
}
#else
public class ObservableValueHolder<ObservableType>: ObserveCapable<ObservableType> {
    open var value: ObservableType
    var options: [ObservableValueHolderOptionKey: Any]?

    public required init(_ value: ObservableType, options: [ObservableValueHolderOptionKey: Any]?) {
        self.value = value
        self.options = options
    }
}
#endif

public extension ObservableValueHolder {
    @discardableResult
    func observe(_ owner: AnyObject,
                 callback: @escaping (ObservableType) -> Void) -> Self {
        callback(value)
        return bind(owner, callback: callback)
    }

    @discardableResult
    func bind(_ owner: AnyObject,
              callback: @escaping (ObservableType, ObservableType) -> Void) -> Self {
        let bind = bindings.object(forKey: owner) ?? Binding()
        bind.oldValueNewValueActions.append(callback)
        bindings.setObject(bind, forKey: owner)
        return self
    }

    @discardableResult
    func bindToOldValue(_ owner: AnyObject,
                        callback: @escaping (ObservableType) -> Void) -> Self {
        let bind = bindings.object(forKey: owner) ?? Binding()
        bind.oldValueActions.append(callback)
        bindings.setObject(bind, forKey: owner)
        return self
    }

    @discardableResult
    func observe(_ owner: AnyObject,
                 callback: @escaping (ObservableType, ObservableType) -> Void) -> Self {
        callback(value, value)
        return bind(owner, callback: callback)
    }
}

public extension ObservableValueHolder {

    func combined<T, R>(with other: Observable<T>,
                        equalBy equalityClosure: ((R, R) -> Bool)?,
                        transform: @escaping (ObservableType, T) -> R) -> Observable<R> {
        let combined = transform(self.value, other.value)
        var options = self.options ?? [:]
        options[.equalityClosure] = equalityClosure
        let observable = Observable(combined, options: options)
        self.bind(observable) { (value) in
            observable.value = transform(self.value, other.value)
        }
        other.bind(observable) { (value) in
            observable.value = transform(self.value, other.value)
        }
        return observable
    }

    func combined<T, R>(with other: Observable<T>,
                        transform: @escaping (ObservableType, T) -> R) -> Observable<R> where R: Equatable {
        return combined(with: other, equalBy: ==, transform: transform)
    }

    func combined<T, R>(with other: ObservableArray<T>,
                        equalBy equalityClosure: ((R, R) -> Bool)?,
                        transform: @escaping (ObservableType, [T]) -> [R]) -> ObservableArray<R> {
        let combined = transform(self.value, other.value)
        var options = self.options ?? [:]
        options[.equalityClosure] = equalityClosure
        let observable = ObservableArray(combined, options: options)
        self.bind(observable) { (value) in
            observable.value = transform(self.value, other.value)
        }
        other.bind(observable) { (value) in
            observable.value = transform(self.value, other.value)
        }
        return observable
    }

    func combined<T, R>(with other: ObservableArray<T>,
                        transform: @escaping (ObservableType, [T]) -> [R]) -> ObservableArray<R> where R: Equatable {
        return combined(with: other, equalBy: ==, transform: transform)
    }
}

public extension ObservableArray {

    func combinedArray<R>(with other: Observable<T>, transform: @escaping ([Element], T) -> R) -> Observable<R> {
        let combined = transform(self.value, other.value)
        let observable = Observable(combined, options: options)
        self.bind(observable) { (value) in
            observable.value = transform(self.value, other.value)
        }
        other.bind(observable) { (value) in
            observable.value = transform(self.value, other.value)
        }
        return observable
    }
}
