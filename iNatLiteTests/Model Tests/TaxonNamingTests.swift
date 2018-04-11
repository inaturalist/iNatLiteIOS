//
//  TaxonNamingTests.swift
//  iNatLiteTests
//
//  Created by Alex Shepard on 4/11/18.
//  Copyright © 2018 iNaturalist. All rights reserved.
//

import XCTest
@testable import iNatLite

class TaxonNamingTests: XCTestCase {
    
    var silkMothTaxon: Taxon!
    var epidendrumSecundumTaxon: Taxon!
    
    override func setUp() {
        super.setUp()
        
        silkMothTaxon = FixtureHelper.silkMothTaxon()
        epidendrumSecundumTaxon = FixtureHelper.epidendrumSecundumTaxon()
    }
    
    func testDisplayNameWithCommonName() {
        XCTAssertEqual(silkMothTaxon.displayName, silkMothTaxon.preferred_common_name?.capitalized, "If there is a common name for a taxon, the display name return it (capitalized)")
    }
    
    func testAnyNameWithoutCommonName() {
        XCTAssertNil(epidendrumSecundumTaxon.preferred_common_name, "Epidendrum Secundum fixture should not have a common name.")
        
        XCTAssertEqual(epidendrumSecundumTaxon.displayName, epidendrumSecundumTaxon.name, "If there is a common name for a taxon, the display name should return it (without changing capitalization)")
    }
}
