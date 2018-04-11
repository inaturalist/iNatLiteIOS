//
//  FixtureHelperTests.swift
//  iNatLiteTests
//
//  Created by Alex Shepard on 4/11/18.
//  Copyright © 2018 iNaturalist. All rights reserved.
//

import XCTest

class FixtureHelperTests: XCTestCase {
    
    func testImageFixtureExists() {
        XCTAssertNotNil(FixtureHelper.imageFromFixture(), "image fixture should exist.")
    }
    
    func testSilkMothTaxonFixtureExists() {
        XCTAssertNotNil(FixtureHelper.silkMothTaxon(), "Silk Moth taxon fixture should exist.")
    }

    func testSoldierFlyTaxonFixtureExists() {
        XCTAssertNotNil(FixtureHelper.soldierFlyTaxon(), "Soldier Fly taxon fixture should exist.")
    }

    func testEpidendrumSecundumTaxonFixtureExists() {
        XCTAssertNotNil(FixtureHelper.epidendrumSecundumTaxon(), "Epidendrum Secundum taxon fixture should exist.")
    }

}
