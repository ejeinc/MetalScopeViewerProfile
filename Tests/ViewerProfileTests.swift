//
//  ViewerProfileTests.swift
//  MetalScopeViewerProfile
//
//  Created by Jun Tanaka on 2017/04/11.
//  Copyright © 2017 eje Inc. All rights reserved.
//

import XCTest
import MetalScope

@testable import MetalScopeViewerProfile

final class ViewerProfileTests: XCTestCase {
    let validData = Data(base64Encoded: "CgZHb29nbGUSEkNhcmRib2FyZCBJL08gMjAxNR2ZuxY9JbbzfT0qEAAASEIAAEhCAABIQgAASEJYADUpXA89OgiCc4Y+MCqJPlAAYAM=")!

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testInitialization() {
        do {
            let profile = try ViewerProfile(serializedData: validData)
            XCTAssertEqual(profile.vendor, "Google")
            XCTAssertEqual(profile.model, "Cardboard I/O 2015")
        } catch {
            XCTFail("Initialization failed with error: \(error)")
        }
    }

    func testSerialization() {
        do {
            let profile1 = try ViewerProfile(serializedData: validData)
            let data = try profile1.serializedData()
            let profile2 = try ViewerProfile(serializedData: data)
            XCTAssertEqual(profile1.vendor, profile2.vendor)
            XCTAssertEqual(profile1.model, profile2.model)
            XCTAssertEqual(profile1.lenses.alignment, profile2.lenses.alignment)
            XCTAssertEqual(profile1.lenses.offset, profile2.lenses.offset)
            XCTAssertEqual(profile1.lenses.screenDistance, profile2.lenses.screenDistance)
            XCTAssertEqual(profile1.lenses.separation, profile2.lenses.separation)
            XCTAssertEqual(profile1.distortion.k1, profile2.distortion.k1)
            XCTAssertEqual(profile1.distortion.k2, profile2.distortion.k2)
            XCTAssertEqual(profile1.maximumFieldOfView.outer, profile2.maximumFieldOfView.outer)
            XCTAssertEqual(profile1.maximumFieldOfView.inner, profile2.maximumFieldOfView.inner)
            XCTAssertEqual(profile1.maximumFieldOfView.upper, profile2.maximumFieldOfView.upper)
            XCTAssertEqual(profile1.maximumFieldOfView.lower, profile2.maximumFieldOfView.lower)
        } catch {
            XCTFail("Serialization failed with error: \(error)")
        }
    }
}
