//
//  CombinationsTests.swift
//  
//
//  Created by Alexander Karpov on 21.01.2021.
//

import XCTest
@testable import Bindy

final class CombinationsTests: XCTestCase {

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

    static var allTests = [
        ("testCombination", testCombination),
        ("testArrayCombination", testArrayCombination)
    ]
}
