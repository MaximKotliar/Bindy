//
//  ObservableArray.swift
//  Bindy
//
//  Created by Maxim Kotliar on 10/31/17.
//  Copyright © 2017 Maxim Kotliar. All rights reserved.
//

import Foundation

public class ObservableArray<T: Equatable>: MutableCollection, CustomStringConvertible, CustomDebugStringConvertible, ExpressibleByArrayLiteral, RangeReplaceableCollection, Equatable {
    
    public typealias Element = T
    
    class Bind {
        var actions: [([T]) -> Void] = []
    }
    
    public required init() {
        array = []
    }
    
    public init(array: [Element]) {
        self.array = array
    }
    
    private var bindings = NSMapTable<AnyObject, Bind>.weakToStrongObjects()
    
    public var array: [T] {
        didSet {
            guard oldValue != array,
                let enumerator = bindings.objectEnumerator() else { return }
            
            enumerator.allObjects.forEach { bind in
                (bind as? Bind)?.actions.forEach { $0(array) }
            }
        }
    }
    
    @discardableResult
    public func observe(_ owner: AnyObject, callback: @escaping ([T]) -> Void) -> Self {
        callback(array)
        return bind(owner, callback: callback)
    }
    
    @discardableResult
    public func bind(_ owner: AnyObject, callback: @escaping ([T]) -> Void) -> Self {
        let bind = bindings.object(forKey: owner) ?? Bind()
        bind.actions.append(callback)
        bindings.setObject(bind, forKey: owner)
        return self
    }
    
    public func unbind(_ owner: AnyObject) {
        bindings.removeObject(forKey: owner)
    }
    
    public var startIndex: Int { return array.startIndex }
    
    public var endIndex: Int { return array.endIndex }
    
    public func index(after i: Int) -> Int { return array.index(after: i) }
    
    public subscript(index: Int) -> T {
        get {
            return array[index]
        }
        set {
            array[index] = newValue
        }
    }
    
    public func index(before i: Int) -> Int {
        return array.index(before: i)
    }
    
    public var description: String {
        return array.description
    }
    
    public var debugDescription: String {
        return array.debugDescription
    }
    
    public required init(arrayLiteral elements: T...) {
        array = Array(elements)
    }
    
    public func replaceSubrange<C>(_ subrange: Range<ObservableArray.Index>,
                                   with newElements: C) where C: Collection,
        C.Iterator.Element == T {
            array.replaceSubrange(subrange, with: newElements)
    }
    
    public func removeLast() {
        array.removeLast()
    }
    
    public static func == (lhs: ObservableArray<T>, rhs: ObservableArray<T>) -> Bool {
        return lhs.array == rhs.array
    }
}
