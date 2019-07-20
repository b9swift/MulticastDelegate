import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(B9MulticastDelegateTests.allTests),
    ]
}
#endif
