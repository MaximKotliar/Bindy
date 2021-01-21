//
//  HighOrderFunctions.swift
//  Bindy
//
//  Created by Maxim Kotliar on 2/24/19.
//  Copyright © 2019 Maxim Kotliar. All rights reserved.
//

import Foundation

public protocol BindyOptionalType {
    associatedtype Wrapped
    var wrapped: Wrapped? { get }
}

extension Optional: BindyOptionalType {
    public var wrapped: Wrapped? {
        return self
    }
}

public extension Observable {
    
    func map<U>(_ transform: @escaping (T) -> U) -> Observable<U> {
        return self.transform(transform)
    }
    
    func map<U: Equatable>(_ transform: @escaping (T) -> U) -> Observable<U> {
        return self.transform(transform)
    }
}

public extension Observable where T: BindyOptionalType {
    
    func flatMap<U>(_ transform: @escaping (T) -> U?) -> Signal<U> {
        let signal = Signal<U>()
        observe(self) { value in
            guard let transformed = transform(value) else { return }
            signal.send(transformed)
        }
        return signal
    }
}

public extension Observable where T: Collection {
    func reduce<Result>(_ initialResult: Result,
                        nextPartialResult: @escaping (Result, T.Element) -> Result) -> Observable<Result> {
        let observable = Observable<Result>(initialResult)
        observe(self) { value in
            observable.value = value.reduce(initialResult, nextPartialResult)
        }
        return observable
    }
    
    func map<Result>(_ transform: @escaping (T.Element) -> Result) -> Observable<[Result]> {
        let observable = Observable<[Result]>([])
        observe(self) { value in
            observable.value = value.map(transform)
        }
        return observable
    }
    
    func filter(_ isIncluded: @escaping (T.Element) -> Bool) -> Observable<[T.Element]> {
        let observable = Observable<[T.Element]>([])
        observe(self) { value in
            observable.value = value.filter(isIncluded)
        }
        return observable
    }
}

public extension Observable where T: Collection, T.Element: BindyOptionalType {
    
    func compactMap<Result>(_ transform: @escaping (T.Element?) -> Result?) -> Observable<[Result]> {
        let observable = Observable<[Result]>([])
        observe(self) { value in
            observable.value = value.compactMap(transform)
        }
        return observable
    }
}
