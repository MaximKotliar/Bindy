//
//  ObservableCompound.swift
//  Bindy
//
//  Created by Maxim Kotliar on 11/7/17.
//  Copyright © 2017 Maxim Kotliar. All rights reserved.
//

//import Foundation
//
//public struct Compound<F, S> {
//    public let first: ObservableValueHolder<F, F>
//    public let second: ObservableValueHolder<S, S>
//}
//
//public final class Compound<U>: ObserveCapable<U, Any> {
//
//    public var first: ObservableValueHolder<F, F> {
//        didSet {
//            oldValue.unbind(self)
//
//        }
//    }
//    public var second: ObservableValueHolder<S, S> {
//        didSet  {
//            oldValue.unbind(self)
//
//        }
//    }
//
//    init(_ observables: Compound<F, S>) {
//        first = observables.first
//        second = observables.second
//    }
//
//    private func setup() {
//        first.unbind(self)
//        first.bind(self, callback: { [unowned self] _ in
//            self.fireBindings(with: (self.first.value, self.second.value))
//        })
//        second.unbind(self)
//        second.bind(self, callback: { [unowned self] _ in
//            self.fireBindings(with: (self.first.value, self.second.value))
//        })
//    }
//}

