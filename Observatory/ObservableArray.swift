//
//  ObservableArray.swift
//  Observatory
//
//  Created by Maxim Kotliar on 10/31/17.
//  Copyright © 2017 Maxim Kotliar. All rights reserved.
//

import Foundation

public class ObservableArray<T: Equatable>: MutableCollection, CustomStringConvertible, CustomDebugStringConvertible, ExpressibleByArrayLiteral, RangeReplaceableCollection, Equatable {
    
    typealias Element = T
    
    class Bind {
        var actions: [Callback<[T]>] = []
    }
    
    required init() {
        array = []
    }
    
    init(array: [Element]) {
        self.array = array
    }
    
    private var bindings = NSMapTable<AnyObject, Bind>.weakToStrongObjects()
    
    var array: [T] {
        didSet {
            guard oldValue != array,
                let enumerator = bindings.objectEnumerator() else { return }
            
            enumerator.allObjects.forEach { bind in
                (bind as? Bind)?.actions.forEach { $0(array) }
            }
        }
    }
    
    @discardableResult
    func observe(_ owner: AnyObject, callback: @escaping Callback<[T]>) -> Self {
        callback(array)
        return bind(owner, callback: callback)
    }
    
    @discardableResult
    func bind(_ owner: AnyObject, callback: @escaping Callback<[T]>) -> Self {
        let bind = bindings.object(forKey: owner) ?? Bind()
        bind.actions.append(callback)
        bindings.setObject(bind, forKey: owner)
        return self
    }
    
    func unbind(_ owner: AnyObject) {
        bindings.removeObject(forKey: owner)
    }
    
    var startIndex: Int { return array.startIndex }
    
    var endIndex: Int { return array.endIndex }
    
    func index(after i: Int) -> Int { return array.index(after: i) }
    
    subscript(index: Int) -> T {
        get {
            return array[index]
        }
        set {
            array[index] = newValue
        }
    }
    
    func index(before i: Int) -> Int {
        return array.index(before: i)
    }
    
    var description: String {
        return array.description
    }
    
    var debugDescription: String {
        return array.debugDescription
    }
    
    required init(arrayLiteral elements: T...) {
        array = Array(elements)
    }
    
    func replaceSubrange<C>(_ subrange: Range<ObservableArray.Index>,
                            with newElements: C) where C: Collection,
        C.Iterator.Element == T {
            var copy = array
            copy.replaceSubrange(subrange, with: newElements)
            swap(&array, &copy)
    }
    
    func removeLast() {
        array.removeLast()
    }
    
    static func == (lhs: ObservableArray<T>, rhs: ObservableArray<T>) -> Bool {
        return lhs.array == rhs.array
    }
}
