//
//  PlaceTests.swift
//  iNatLiteTests
//
//  Created by Alex Shepard on 3/19/18.
//  Copyright © 2018 iNaturalist. All rights reserved.
//

import XCTest
@testable import iNatLite

class PlaceTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testStatePlaceTypeName() {
        let statePlace = Place(id: 0, name: "", display_name: "", admin_level: nil, place_type: 8, bounding_box_geojson: nil)
        XCTAssertEqual(statePlace.place_type_name, "State", "a place with a type of 8 should have a place type name of \"State\"")
    }
    
    func testEmptyPlaceTypeName() {
        let noTypePlace = Place(id: 1, name: "", display_name: "", admin_level: nil, place_type: nil, bounding_box_geojson: nil)
        XCTAssertEqual(noTypePlace.place_type_name, nil, "a place without a place type should have a place type name of nil")
    }
}
