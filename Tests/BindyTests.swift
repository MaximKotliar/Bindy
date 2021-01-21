import XCTest
import UIKit
@testable import Bindy

class TestListener: NSObject {
    var tag = 0
}

final class BindyTests: XCTestCase {
    
    var observable: Observable<String>?
    var kvoObservable: Observable<CGRect>?
    var optionalObservable: Observable<String?>?
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
        optionalObservable = Observable(old)
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

    let firstname = Observable("Maxim")
    let lastname = Observable("Kotliar")
    let age = Observable(24)

    lazy var userInfo = {
        return firstname
            .combined(with: lastname) { "\($0) \($1)" }
            .combined(with: age) { "\($0) \($1)" }
    }()

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

    func testBoolCombine() {
        testObservableListener = TestListener()
        let isPremiumPurchased = Observable(false)
        let isTrialPeriodEnded = Observable(false)
        let isAdsShowForced = Observable(false)
        let shouldShowAds = isAdsShowForced || !isPremiumPurchased && isTrialPeriodEnded
        XCTAssert(shouldShowAds.value == false)
        isTrialPeriodEnded.value = true
        XCTAssert(shouldShowAds.value == true)
        isPremiumPurchased.value = true
        XCTAssert(shouldShowAds.value == false)
        isPremiumPurchased.value = false
        isAdsShowForced.value = true
        XCTAssert(shouldShowAds.value == true)
        let asyncExpectation = expectation(description: "Expect to call")
        shouldShowAds.bind(testObservableListener!) { result in
            XCTAssert(!result)
            asyncExpectation.fulfill()
        }
        isAdsShowForced.value = false
        isPremiumPurchased.value = false
        isTrialPeriodEnded.value = false
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testEquatableCallsReduce() {
        let string = Observable("test")
        let asyncExpectation = expectation(description: "Expect to call once")
        string.bind(self) { _ in
            asyncExpectation.fulfill()
        }
        string.value = "test"
        string.value = "test"
        string.value = "asdasd"
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testOptionalEquatableCallsReduce() {
        let string: Observable<String?> = Observable(nil)
        let asyncExpectation = expectation(description: "Expect to call once")
        string.bind(self) { _ in
            asyncExpectation.fulfill()
        }
        string.value = nil
        string.value = "test"
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testNonEquatableCalls() {
        struct NonEquatable {}
        let observable = Observable(NonEquatable())
        let asyncExpectation = expectation(description: "Expect to call 3 times")
        var callsCount = 0
        observable.bind(self) { _ in
            callsCount += 1
            if callsCount == 3 {
                asyncExpectation.fulfill()
            }
        }
        observable.value = NonEquatable()
        observable.value = NonEquatable()
        observable.value = NonEquatable()
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testObservableWithOldValue() {
        let observable = Observable<String?>(nil)
        let asyncExpectation = expectation(description: "Expect to call")
        observable.bind(self) { oldValue, newValue in
            guard oldValue == nil, newValue == "test" else { return }
            asyncExpectation.fulfill()
        }
        observable.value = "test"
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testObservableWithOldValueOnly() {
        let observable = Observable<String?>(nil)
        let asyncExpectation = expectation(description: "Expect to call")
        observable.bindToOldValue(self) { oldValue in
            guard oldValue == nil else { return }
            asyncExpectation.fulfill()
        }
        observable.value = "test"
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testEquatableTransformEqualityCheck() {
        struct NonEquatable {
            let test: String
        }
        let nonEquatable = Observable(NonEquatable(test: "1"))
        let equatable = nonEquatable.transform { $0.test }

        let nonEuqatableExpectation = expectation(description: "Expect to call twice")
        var callCount = 0
        nonEquatable.bind(self) { _ in
            callCount += 1
            if callCount == 2 {
                nonEuqatableExpectation.fulfill()
            }
        }
        let euqatableExpectation = expectation(description: "Expect to call once")
        equatable.bind(self) { _ in
            euqatableExpectation.fulfill()
        }
        nonEquatable.value = NonEquatable(test: "2")
        nonEquatable.value = NonEquatable(test: "2")
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testKVOObservable() {
        let view = UIView()
        let observable = view.observable(for: \.frame)
        let asyncExpectation = expectation(description: "Expect to call")
        observable.bind(self) { old, new in
            guard old.width == 0 else { return }
            guard new.width == 1 else { return }
            asyncExpectation.fulfill()
        }
        view.frame = CGRect(x: 1, y: 1, width: 1, height: 1)
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testKVOObservableCleanup() {
        testObservableListener = TestListener()
        let view = UIView()
        kvoObservable = view[\.frame]

        let bindNotCallExpectation = expectation(description: "bind did not call")
        bindNotCallExpectation.isInverted = true

        kvoObservable!.bind(testObservableListener!) { newValue in
            self.testObservableListener!.tag = 4
            bindNotCallExpectation.fulfill()
        }
        // Force listener to release
        testObservableListener = nil
        // Perform change
        view.frame = CGRect(x: 1, y: 1, width: 1, height: 1)
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testMap() {
        let observable = Observable<String>("test")
        let mapped = observable.map { $0.count }
        let asyncExpectation = expectation(description: "Expect to call")
        mapped.bind(self) { old, new in
            guard old == 4 else { return }
            guard new == 0 else { return }
            asyncExpectation.fulfill()
        }
        observable.value = ""
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testArrayMap() {
        let observable = Observable(["one", "two", "three"])
        let mapped: Observable<[Int]> = observable.map { $0.count }
        let asyncExpectation = expectation(description: "Expect to call")
        mapped.bind(self) { old, new in
            guard old == [3, 3, 5] else { return }
            guard new == [4] else { return }
            asyncExpectation.fulfill()
        }
        observable.value = ["four"]
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testCompactMap() {
        let observable = Observable(["test", "test" , nil])
        let compactMapped = observable.compactMap { $0 }
        let asyncExpectation = expectation(description: "Expect not call")
        asyncExpectation.isInverted = true
        compactMapped.bind(self) { value in
            guard value == ["test", "test", "test"] else { return }
            asyncExpectation.fulfill()
        }
        observable.value.append("test")
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testReduce() {
        let observable = Observable(["test", "test"])
        let reduced = observable.reduce(0) { $0 + $1.count }
        let asyncExpectation = expectation(description: "Expect to call")
        reduced.bind(self) { value in
            guard value == 12 else { return }
            asyncExpectation.fulfill()
        }
        observable.value.append("test")
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testFilter() {
        let observable = Observable(["test", "test", "notTest"])
        let filtered = observable.filter { $0 == "test" }
        let asyncExpectation = expectation(description: "Expect to call")
        filtered.bind(self) { value in
            guard value.count == 3 else { return }
            asyncExpectation.fulfill()
        }
        observable.value.append("test")
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testCombinedCallsReduceByEquality() {
        struct NonEquatable {
            let test: String
        }
        let string = Observable(NonEquatable(test: "test"))
        let secondString = Observable(NonEquatable(test: "test"))
        let bothEmpty = string.combined(with: secondString) { ($0.test + $1.test).isEmpty }
        let euqatableExpectation = expectation(description: "Expect to call once")
        bothEmpty.bind(self) { _ in
            euqatableExpectation.fulfill()
        }
        string.value = NonEquatable(test: "")
        secondString.value = NonEquatable(test: "")
        secondString.value = NonEquatable(test: "")
        string.value = NonEquatable(test: "")
        waitForExpectations(timeout: 1, handler: nil)
    }

    #if swift(>=5.1)
    func testDynamicMemberLookup() {
        let view = UIView()
        let observable = Observable(view)
        observable.tag = 1
        XCTAssert(observable.tag == 1)
    }

    @Observable var propertyWrappedObservable = 0

    func testObservablePropertyWrapper() {
        let asyncExpectation = expectation(description: "Expect to call")
        $propertyWrappedObservable.bind(self) { tag in
            XCTAssert(tag == 1)
            asyncExpectation.fulfill()
        }
        propertyWrappedObservable = 1
        XCTAssert(propertyWrappedObservable == 1)
        waitForExpectations(timeout: 1, handler: nil)
    }
    #endif

    func testTransformedObserverChain() {
        let view = UIView()
        let transformed = view[\.tag].map { $0 + $0 }
        let asyncExpectation = expectation(description: "Expect to call")
        transformed.bind(self) { tag in
            XCTAssert(tag == 4)
            asyncExpectation.fulfill()
        }
        view.tag = 2
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testLeadingDebounce() {
        let val = Observable(0)
        let debounced = val.debounced(3, edge: .leading)
        let asyncExpectation = expectation(description: "Expect to call")
        debounced.bind(self) { val in
            if val == 1 {
                asyncExpectation.fulfill()
            } else {
                XCTFail("debounced allowed passage of second event, but shouldn't")
            }
        }
        val.value = 1
        val.value = 2
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testTrailingDebounce() {
        let val = Observable(0)
        let debounced = val.debounced(1, edge: .trailing)
        let asyncExpectation = expectation(description: "Expect to call")
        debounced.bind(self) { val in
            if val == 1 {
                XCTFail("First change shouldn't trigger binding")
            }
            if val == 2 {
                asyncExpectation.fulfill()
            }
        }
        val.value = 1
        val.value = 2
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testObserveSingleEvent() {
        let value = Observable(0)
        let asyncExpectation = expectation(description: "Expect to call")
        let token = value.observeSingleEvent(matching: { (1...5).contains($0) }) { value in
            print("call \(value)")
            if value == 1 {
                asyncExpectation.fulfill()
            } else if value == 10 {
                XCTFail("Condition not works")
            } else {
                XCTFail("Second change shouldn't trigger binding")
            }
        }
        value.value = 10
        value.value = 1
        value.value = 2
        DispatchQueue.main.async { [weak token] in
            XCTAssert(token == nil)
        }

        waitForExpectations(timeout: 1, handler: nil)
    }


    static var allTests = [
        ("testObservable", testObservable),
        ("testObservableCleanup", testObservableCleanup),
        ("testOptionalObservable", testOptionalObservable),
        ("testObservableArray", testObservableArray),
        ("testSignal", testSignal),
        ("testArrayUpdates", testArrayUpdates),
        ("testCombination", testCombination),
        ("testArrayCombination", testArrayCombination),
        ("testTransform", testTransform),
        ("testTransformCleanup", testTransformCleanup),
        ("testUIViewIsHidden", testUIViewIsHidden),
        ("testUIViewIsUserInteractionEnabled", testUIViewIsUserInteractionEnabled),
        ("testUIViewAlpha", testUIViewAlpha),
        ("testBoolCombine", testBoolCombine),
        ("testEquatableCallsReduce", testEquatableCallsReduce),
        ("testOptionalEquatableCallsReduce", testOptionalEquatableCallsReduce),
        ("testObservableWithOldValue", testObservableWithOldValue),
        ("testObservableWithOldValueOnly", testObservableWithOldValueOnly),
        ("testEquatableTransformEqualityCheck", testEquatableTransformEqualityCheck),
        ("testKVOObservable", testKVOObservable),
        ("testMap", testMap),
        ("testArrayMap", testArrayMap),
        ("testCompactMap", testCompactMap),
        ("testReduce", testReduce),
        ("testFilter", testFilter),
        ("testCombinedCallsReduceByEquality", testCombinedCallsReduceByEquality),
        ("testDynamicMemberLookup", testDynamicMemberLookup),
        ("testObservablePropertyWrapper", testObservablePropertyWrapper),
        ("testTransformedObserverChain", testTransformedObserverChain),
        ("testLeadingDebounce", testLeadingDebounce),
        ("testTrailingDebounce", testTrailingDebounce),
        ("testObserveSingleEvent", testObserveSingleEvent)
    ]
}
