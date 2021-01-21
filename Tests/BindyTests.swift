import XCTest
@testable import Bindy

class TestListener: NSObject {
    var tag = 0
}

final class BindyTests: XCTestCase {

    var testObservableListener: TestListener?
    var kvoObservable: Observable<CGRect>?
    var optionalObservable: Observable<String?>?
    var observableArray: ObservableArray<String>?
    var signal: Signal<String>?
    
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

    
}

extension BindyTests {
    static var allTests = [
        ("testSignal", testSignal),
        ("testArrayUpdates", testArrayUpdates),
        ("testTransform", testTransform),
        ("testTransformCleanup", testTransformCleanup),
        ("testBoolCombine", testBoolCombine),
        ("testEquatableCallsReduce", testEquatableCallsReduce),
        ("testOptionalEquatableCallsReduce", testOptionalEquatableCallsReduce),
        ("testEquatableTransformEqualityCheck", testEquatableTransformEqualityCheck),
        ("testCombinedCallsReduceByEquality", testCombinedCallsReduceByEquality),
        ("testDynamicMemberLookup", testDynamicMemberLookup),
        ("testObservablePropertyWrapper", testObservablePropertyWrapper),
        ("testTransformedObserverChain", testTransformedObserverChain),
        ("testLeadingDebounce", testLeadingDebounce),
        ("testTrailingDebounce", testTrailingDebounce),
        ("testObserveSingleEvent", testObserveSingleEvent)
    ]
}
