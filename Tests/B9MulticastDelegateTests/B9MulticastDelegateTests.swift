import XCTest
@testable import B9MulticastDelegate


protocol TestSwiftProtocol {
    func kindString() -> String
}

struct TestKindA: TestSwiftProtocol {
    func kindString() -> String {
        return "Kind: A"
    }
}

class TestKindB: TestSwiftProtocol {
    func kindString() -> String {
        return "Kind: B"
    }
}

class TestKindC {
    func throwError() throws {
        throw NSError(domain: "", code: 0, userInfo: nil)
    }
}

final class B9MulticastDelegateTests: XCTestCase {

    func testAddAndRemove() {
        let a = TestKindA()
        let b1 = TestKindB()
        let b2 = TestKindB()

        let d = MulticastDelegate<TestSwiftProtocol>()
        d.add(nil)
        XCTAssert(d.debugContent == [])
        d.add(a)
        XCTAssert(d.debugContent == [], "Add non-object takes no effect.")
        print(d)

        d.add(b1)
        XCTAssert(d.debugContent == [b1])
        d.add(b1)
        XCTAssert(d.debugContent == [b1], "Adding multiple times has no effect.")
        print(d)

        d.add(b2)
        XCTAssert(d.debugContent == [b1, b2])
        print(d)

        d.remove(b1)
        XCTAssert(d.debugContent == [b2])

        d.remove(b1)
        XCTAssert(d.debugContent == [b2])

        d.remove(nil)
        XCTAssert(d.debugContent == [b2])

        d.remove(b2)
        XCTAssert(d.debugContent == [])
    }

    func testSwiftObjContains() {
        var result: Bool
        let b1 = TestKindB()
        let b2 = TestKindB()
        let d = MulticastDelegate<TestKindB>()
        d.add(b1)
        XCTAssertTrue(d.contains(object: b1))
        XCTAssertFalse(d.contains(object: b2))
        result = d.contains { o -> Bool in
            return o === b1
        }
        XCTAssertTrue(result)
        d.remove(b1)
        XCTAssertFalse(d.contains(object: b1))
    }

    func testNSObjectContains() {
        var result: Bool
        let otherObj = XCTestCase()
        let d2 = MulticastDelegate<XCTActivity>()
        d2.add(self)
        XCTAssertTrue(d2.contains(object: self))
        XCTAssertFalse(d2.contains(object: otherObj))
        result = d2.contains { o -> Bool in
            return o === self
        }
        XCTAssertTrue(result)
        d2.remove(self)
        XCTAssertFalse(d2.contains(object: self))
    }

    func testWeakRef() {
        let d = MulticastDelegate<XCTestCase>()
        autoreleasepool {
            let obj = XCTestCase()
            d.add(obj)
            XCTAssert(d.debugContent == [obj])
        }
        XCTAssert(d.debugContent == [], "The object should now be released.")
    }

    func testInvokeErrorHandling() {
        let d = MulticastDelegate<TestKindC>()
        let c1 = TestKindC()
        let c2 = TestKindC()
        d.add(c1)
        d.add(c2)

        var errorCount = 0
        // Catch inside
        d.invoke { c in
            do {
                try c.throwError()
            } catch {
                print(error)
                errorCount += 1
            }
        }
        XCTAssertEqual(errorCount, 2)

        errorCount = 0
        // Catch outside
        do {
            try d.invoke { c in
                try c.throwError()
            }
        } catch {
            print(error)
            errorCount += 1
        }
        XCTAssertEqual(errorCount, 1)
    }
}

// MARK: -
extension MulticastDelegate {
    var debugContent: [AnyObject] {
        return compactMap { $0 as AnyObject }
    }
}

func == (lhs: [AnyObject], rhs: [AnyObject]) -> Bool {
    guard lhs.count == rhs.count else { return false }
    for i in 0 ..< lhs.count {
        if lhs[i] !== rhs[i] {
            return false
        }
    }
    return true
}

