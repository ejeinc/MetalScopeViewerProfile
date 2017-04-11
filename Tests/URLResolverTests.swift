//
//  URLResolverTests.swift
//  MetalScopeViewerProfile
//
//  Created by Jun Tanaka on 2017/04/11.
//  Copyright © 2017 eje Inc. All rights reserved.
//

import XCTest

@testable import MetalScopeViewerProfile

final class URLResolverTests: XCTestCase {
    let unresolvedURL = URL(string: "http://goo.gl/R2gCV1")!
    let resolvedURL = URL(string: "https://vr.google.com/cardboard/download/?p=CgZHb29nbGUSEkNhcmRib2FyZCBJL08gMjAxNR2ZuxY9JbbzfT0qEAAASEIAAEhCAABIQgAASEJYADUpXA89OgiCc4Y-MCqJPlAAYAM")!

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testResolveWithResolvedURL() {
        let expectation = XCTestExpectation(description: "Resolved")

        let resolver = URLResolver()
        resolver.resolve(url: resolvedURL) { data, error in
            if let error = error {
                XCTFail("Failed with error: \(error)")
            } else if let data = data {
                do {
                    let _ = try ViewerProfile(serializedData: data)
                    expectation.fulfill()
                } catch {
                    XCTFail("Completed with invalid data")
                }
            } else {
                XCTFail("Completed without any data nor error")
            }
        }

        wait(for: [expectation], timeout: 5)
    }

    func testResolveWithUnresolvedURL() {
        let expectation = XCTestExpectation(description: "Resolved")

        let resolver = URLResolver()
        resolver.resolve(url: unresolvedURL) { data, error in
            if let error = error {
                XCTFail("Failed with error: \(error)")
            } else if let data = data {
                do {
                    let _ = try ViewerProfile(serializedData: data)
                    expectation.fulfill()
                } catch {
                    XCTFail("Completed with invalid data")
                }
            } else {
                XCTFail("Completed without any data nor error")
            }
        }
    }

    func testResolveWithInvalidURL() {
        let expectation = XCTestExpectation(description: "Failed with Error.invalidURL")

        let invalidURL = URL(string: "https://vr.google.com/cardboard/")!

        let resolver = URLResolver()
        resolver.resolve(url: invalidURL) { _, error in
            guard let error = error else {
                XCTFail("Succeed with an invalid URL")
                return
            }
            switch error {
            case .invalidURL:
                expectation.fulfill()
            default:
                XCTFail("Failed with an unexpected error: \(error)")
            }
        }

        wait(for: [expectation], timeout: 5)
    }

    func testCancel() {
        let expectation = XCTestExpectation(description: "Failed with Error.cancelled")

        let resolver = URLResolver()
        let token = resolver.resolve(url: unresolvedURL) { resolvedURL, error in
            guard let error = error else {
                XCTFail("Cancelled but succeed")
                return
            }
            switch error {
            case .cancelled:
                expectation.fulfill()
            default:
                XCTFail("Failed with an unexpected error: \(error)")
            }
        }
        token?.cancel()

        wait(for: [expectation], timeout: 5)
    }
}
