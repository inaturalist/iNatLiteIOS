//
//  UIImageInatLiteExTests.swift
//  iNatLiteTests
//
//  Created by Alex Shepard on 4/5/18.
//  Copyright © 2018 iNaturalist. All rights reserved.
//

import XCTest
@testable import iNatLite

class UIImageInatLiteExTests: XCTestCase {
    
    func testNegativeObservationsProfileImage() {
        XCTAssertNil(UIImage.profileIconNameForObservationCount(-1), "Negative observation count should have a nil profile image name.")
        XCTAssertNil(UIImage.profileIconForObservationCount(-1), "Negative observation count should have a nil profile image.")
    }
    
    func testZeroObservationsProfileImage() {
        XCTAssertEqual(UIImage.profileIconNameForObservationCount(0), "icn-profile-egg", "Zero observations should have the egg profile name.")
        XCTAssertNotNil(UIImage.profileIconForObservationCount(0), "Zero observations should have a profile image.")
    }
    
    func testOneObservationsProfileImage() {
        XCTAssertEqual(UIImage.profileIconNameForObservationCount(1), "icn-profile-egg-crack-1", "One observation should have the egg with 1 crack.")
        XCTAssertNotNil(UIImage.profileIconForObservationCount(1), "One observation should have a profile image.")
    }
    
    func testTwoObservationsProfileImage() {
        XCTAssertEqual(UIImage.profileIconNameForObservationCount(2), "icn-profile-egg-crack-2", "Two observations should have the crack with 2 cracks.")
        XCTAssertNotNil(UIImage.profileIconForObservationCount(2), "Two observations should have a profile image.")
    }

    func testThreeObservationsProfileImage() {
        XCTAssertEqual(UIImage.profileIconNameForObservationCount(3), "icn-profile-tadpole", "Three observations should have the tadpole.")
        XCTAssertNotNil(UIImage.profileIconForObservationCount(3), "Three observations should have a profile image.")
    }

    func testNineteenObservationProfileImage() {
        XCTAssertEqual(UIImage.profileIconNameForObservationCount(19), "icn-profile-cub", "19 observations should have the cub.")
        XCTAssertNotNil(UIImage.profileIconForObservationCount(19), "19 observations should have a profile image.")
    }
    
    func testFourtyObservationsProfileImage() {
        XCTAssertEqual(UIImage.profileIconNameForObservationCount(40), "icn-profile-surveyor", "40 observations should have the surveyor.")
        XCTAssertNotNil(UIImage.profileIconForObservationCount(40), "40 observations should have a profile image.")
    }

    func testObservationsProfileImage() {
        XCTAssertEqual(UIImage.profileIconNameForObservationCount(70), "icn-profile-naturalist", "70 observations should have the naturalist.")
        XCTAssertNotNil(UIImage.profileIconForObservationCount(70), "70 observations should have a profile image.")
    }

    func testOneTenObservationsProfileImage() {
        XCTAssertEqual(UIImage.profileIconNameForObservationCount(110), "icn-profile-explorer", "110 observations should have the explorer.")
        XCTAssertNotNil(UIImage.profileIconForObservationCount(110), "110 observations should have a profile image.")
    }
    
    func testImageResize() {
        let image = FixtureHelper.imageFromFixture()
        XCTAssertNotNil(image, "image from fixture should not be nil")
        let newSize = CGSize(width: 299, height: 299)
        let resized = image!.resizedTo(newSize)
        XCTAssertNotNil(resized, "resized image from fixture should not be nil")
        XCTAssertEqual(resized!.size, newSize, "resized image from fixture should be the correct size")
    }
}
