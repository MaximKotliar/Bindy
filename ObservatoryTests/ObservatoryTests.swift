//
//  ObservatoryTests.swift
//  ObservatoryTests
//
//  Created by Maxim Kotliar on 10/31/17.
//  Copyright © 2017 Maxim Kotliar. All rights reserved.
//

import XCTest
@testable import Observatory

class ObservatoryTests: XCTestCase {
    
    var observable: Observable<String>?
    var optionalObservable: OptionalObservable<String>?
    var observableArray: ObservableArray<String>?
    var signal: Signal<String>?
    
    func testObservable() {
        let old = "Test"
        let new = "Test_New"
        let asyncExpectation = expectation(description: "")
        observable = Observable(old)
        observable?.bind(self, callback: { (newValue) in
            guard newValue == new else { return }
            asyncExpectation.fulfill()
        })
        observable?.value = new
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testOptionalObservable() {
        let old = "Test"
        let new: String? = nil
        let asyncExpectation = expectation(description: "")
        optionalObservable = OptionalObservable(old)
        optionalObservable?.bind(self, callback: { (newValue) in
            guard newValue == new else { return }
            asyncExpectation.fulfill()
        })
        optionalObservable?.value = new
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testObservableArray() {
        let old = ["Test"]
        let new = ["Test", "1", "2", "3", "4"]
        let asyncExpectation = expectation(description: "")
        observableArray = ObservableArray(old)
        observableArray?.bind(self, callback: { (newValue) in
            guard newValue == new else { return }
            asyncExpectation.fulfill()
        })
        observableArray?.append(contentsOf: ["1", "2", "3", "4"])
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testSignal() {
        let testSignal = "Test"
        let asyncExpectation = expectation(description: "Got signal")
        signal = Signal<String>()
        signal?.bind(self) { (recieved) in
            guard recieved == testSignal else {
                return
            }
            asyncExpectation.fulfill()
        }
        signal?.send(testSignal)
        waitForExpectations(timeout: 1, handler: nil)
    }
}
