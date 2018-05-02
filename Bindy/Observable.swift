//
//  Observable.swift
//  Bindy
//
//  Created by Maxim Kotliar on 10/31/17.
//  Copyright © 2017 Maxim Kotliar. All rights reserved.
//

import Foundation

public final class Observable<T: Equatable>: ObservableValueHolder<T> {

    public override var value: T {
        didSet {
            guard oldValue != self.value else { return }
            fireBindings(with: value)
        }
    }
}

extension Observable {

    func transform<U: Equatable>(_ transform: @escaping (T) -> U) -> Observable<U> {
        let transformedObserver = Observable<U>(transform(value))
        observe(self) { [unowned self] (value) in
            transformedObserver.value = transform(self.value)
        }
        return transformedObserver
    }
}
