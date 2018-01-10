//
//  BindyTests.swift
//  BindyTests
//
//  Created by Maxim Kotliar on 10/31/17.
//  Copyright © 2017 Maxim Kotliar. All rights reserved.
//

import XCTest
@testable import Bindy

class TestListener: NSObject {
    var tag = 0
}

class BindyTests: XCTestCase {

    var observable: Observable<String>?
    var optionalObservable: OptionalObservable<String>?
    var observableArray: ObservableArray<String>?
    var signal: Signal<String>?

    func testObservable() {
        let old = "Test"
        let new = "Test_New"
        let bindCallExpectation = expectation(description: "bind did call")
        observable = Observable(old)
        observable?.bind(self) { (newValue) in
            guard newValue == new else { return }
            bindCallExpectation.fulfill()
        }
        observable?.value = new
        waitForExpectations(timeout: 1, handler: nil)
    }

    var testObservableListener: TestListener?
    func testObservableCleanup() {
        testObservableListener = TestListener()
        observable = Observable("testString")

        let bindNotCallExpectation = expectation(description: "bind did not call")
        bindNotCallExpectation.isInverted = true

        observable!.bind(testObservableListener!) { newValue in
            self.testObservableListener!.tag = 3
            bindNotCallExpectation.fulfill()
        }
        // Force listener to release
        testObservableListener = nil
        // Perform change
        observable?.value = "testObservableCleanup"
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
        let newValueExpectation = expectation(description: "newValue")
        observableArray = ObservableArray(old)
        observableArray?.bind(self, callback: { (newValue) in
            if newValue == new {
                newValueExpectation.fulfill()
            }
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

    func testArrayUpdates() {
        let array = ObservableArray(["1", "2", "3", "4", "5"])
        var insertions: [Int] = []
        var replacements: [Int] = []
        array.observe(self) { (new) in
            XCTAssert(new == ["1", "2", "3", "4", "5"])
        }
        array.unbind(self)
        array.updates.bind(self) { (updates) in
            updates.forEach({ (update) in
                switch update.event {
                case .insert:
                    insertions = update.indexes
                case .replace:
                    replacements = update.indexes
                default:
                    break
                }
            })
        }
        array.replaceAll(with: ["5", "4", "3", "2", "1", "0"])
        XCTAssert(insertions == [5] && replacements == [0, 1, 3, 4])
    }

    func testCombination() {
        enum Mode {
            case cap
            case lower
            case def
        }
        let firstname = Observable("Maxim")
        let age = Observable(24)
        let mode = Observable(Mode.def)

        var callCount = 0
        firstname.combined(with: mode) { name, mode -> String in
            switch mode {
            case .cap:
                return name.uppercased()
            case .lower:
                return name.lowercased()
            case .def:
                return name
            }
            }.combined(with: age) { "\($0) \($1)" }.bind(self) { (res) in
                print(res)
                callCount += 1
        }

        firstname.value = "Maximus"
        mode.value = .lower
        age.value = 25
        mode.value = .cap
        XCTAssert(callCount == 4)
    }

    func testArrayCombination() {

        let tasks = ObservableArray(["one", "two", "three"])
        let priority = ObservableArray([10, 20, 30])
        let title = Observable("Tasks")

        var callCount = 0
        tasks.combined(with: priority) { (tasks, priority) -> [String] in
            return zip(tasks, priority).map { "\($0.0) \($0.1)" }
            }.combined(with: title) { (array, title) -> String in
                return "\(title): [\(array.joined(separator: ", "))]"
            }.observe(self) { (result) in
                print(result)
                    callCount += 1
        }

        tasks.append("four")
        priority.append(4)
        tasks.append("five")
        priority.append(5)
        tasks.append("six")
        title.value = "Schedule"
        priority.append(6)
        tasks.remove(at: 2)
        priority.remove(at: 2)
        XCTAssert(callCount == 7)
    }

    func testTransform() {
        let intValue = Observable(20)
        let stringValue = intValue.transform { return "\($0)"}
        stringValue.bind(self) { string in
            XCTAssert(string == "420")
        }
        intValue.value = 420
        XCTAssert(stringValue.value != "20")
    }

    func testTransformCleanup() {
        testObservableListener = TestListener()
        let intValue = Observable(20)
        let stringValue = intValue.transform { return "\($0)"}
        let asyncExpectation = expectation(description: "Expect not call")
        asyncExpectation.isInverted = true
        stringValue.bind(testObservableListener!) { string in
            self.testObservableListener!.tag = 12
            asyncExpectation.fulfill()
            XCTAssert(string == "420")
        }
        testObservableListener = nil
        intValue.value = 420
        XCTAssert(stringValue.value != "20")
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testUIViewIsHidden() {
        let isHidden = Observable(false)
        var view: UIView? = UIView()
        view?.bind.isHidden.to(isHidden)
        isHidden.value = true
        XCTAssert(view?.isHidden == true)
        isHidden.value = false
        XCTAssert(view?.isHidden == false)
        isHidden.value = true
        XCTAssert(view?.isHidden == true)
        isHidden.unbind(view!)
        view?.bind.isHidden.to(isHidden, inverted: true)
        isHidden.value = false
        XCTAssert(view?.isHidden == true)
        view = nil
        isHidden.value = false
    }

    func testUIViewIsUserInteractionEnabled() {
        let isUserInteractionEnabled = Observable(false)
        var view: UIView? = UIView()
        view?.bind.isUserInteractionEnabled.to(isUserInteractionEnabled)
        isUserInteractionEnabled.value = true
        XCTAssert(view?.isUserInteractionEnabled == true)
        isUserInteractionEnabled.value = false
        XCTAssert(view?.isUserInteractionEnabled == false)
        isUserInteractionEnabled.value = true
        XCTAssert(view?.isUserInteractionEnabled == true)
        view = nil
        isUserInteractionEnabled.value = false
    }

    func testUIViewAlpha() {
        let view = UIView()
        let alpha = Observable<CGFloat>(0)
        view.bind.alpha.to(alpha)
        XCTAssert(view.alpha == alpha.value)
        alpha.value = 0.5
        XCTAssert(view.alpha == alpha.value)
    }
}
