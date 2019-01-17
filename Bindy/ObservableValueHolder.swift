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
    public static let comparisonClosure: ObservableValueHolderOptionKey = "comparisonClosure"
}

public class ObservableValueHolder<ObservableType>: ObserveCapable<ObservableType> {

    open var value: ObservableType

    var options: [ObservableValueHolderOptionKey: Any]?

    @discardableResult
    public func observe(_ owner: AnyObject,
                        callback: @escaping (ObservableType) -> Void) -> Self {
        callback(value)
        return bind(owner, callback: callback)
    }

    public required init(_ value: ObservableType, options: [ObservableValueHolderOptionKey: Any]?) {
        self.value = value
        self.options = options
    }
}

public extension ObservableValueHolder {

    public func combined<T, R>(with other: Observable<T>,
                             transform: @escaping (ObservableType, T) -> R) -> Observable<R> {
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

    public func combined<T, R>(with other: ObservableArray<T>,
                             transform: @escaping (ObservableType, [T]) -> [R]) -> ObservableArray<R> {
        let combined = transform(self.value, other.value)
        let observable = ObservableArray(combined, options: options)
        self.bind(observable) { (value) in
            observable.value = transform(self.value, other.value)
        }
        other.bind(observable) { (value) in
            observable.value = transform(self.value, other.value)
        }
        return observable
    }
}

public extension ObservableArray {

    public func combinedArray<R>(with other: Observable<T>, transform: @escaping ([Element], T) -> R) -> Observable<R> {
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
