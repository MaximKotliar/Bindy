//
//  ObservableValueHolder.swift
//  Bindy
//
//  Created by Maxim Kotliar on 11/6/17.
//  Copyright © 2017 Maxim Kotliar. All rights reserved.
//

import Foundation

public class ObservableValueHolder<ObservableType>: ObserveCapable<ObservableType> {

    open var value: ObservableType

    @discardableResult
    public func observe(_ owner: AnyObject,
                        callback: @escaping (ObservableType) -> Void) -> Self {
        callback(value)
        return bind(owner, callback: callback)
    }

    public init(_ value: ObservableType) {
        self.value = value
    }
}

public extension ObservableValueHolder {

    public func combined<T, R>(with other: Observable<T>,
                             transform: @escaping (ObservableType, T) -> R) -> Observable<R> {
        let combined = transform(self.value, other.value)
        let observable = Observable(combined)
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
        let observable = ObservableArray(combined)
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
        let observable = Observable(combined)
        self.bind(observable) { (value) in
            observable.value = transform(self.value, other.value)
        }
        other.bind(observable) { (value) in
            observable.value = transform(self.value, other.value)
        }
        return observable
    }
}
