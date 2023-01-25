//
//  XCTestCase+Helpers.swift
//  PhotoComTests
//
//  Created by Ryan Gilbert on 1/30/23.
//

import XCTest

extension XCTestCase {
    func waitFor(block: @escaping () -> Bool) {
        // Wait for Call to Complete
        let predicate = NSPredicate { _, _ in
            block()
        }
        let expectation = expectation(for: predicate, evaluatedWith: nil)
        wait(for: [expectation], timeout: 2)
    }
}
