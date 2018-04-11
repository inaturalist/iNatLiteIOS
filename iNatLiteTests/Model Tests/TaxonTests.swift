//
//  TaxonTests.swift
//  iNatLiteTests
//
//  Created by Alex Shepard on 4/11/18.
//  Copyright © 2018 iNaturalist. All rights reserved.
//

import XCTest
@testable import iNatLite

class TaxonTests: XCTestCase {
    
    var silkMothTaxon: Taxon!
    var epidendrumSecundumTaxon: Taxon!
    var ochreSeaStarTaxon: Taxon!

    override func setUp() {
        super.setUp()
        
        silkMothTaxon = FixtureHelper.silkMothTaxon()
        epidendrumSecundumTaxon = FixtureHelper.epidendrumSecundumTaxon()
        ochreSeaStarTaxon = FixtureHelper.ochreSeaStarTaxon()
    }
    
    func testIconicTaxa() {
        XCTAssertEqual(silkMothTaxon.iconicTaxon(), Taxon.Iconic.Insects, "silk moth iconic taxon should be insecta")
        XCTAssertEqual(epidendrumSecundumTaxon.iconicTaxon(), Taxon.Iconic.Plant, "epidendrum secunudum iconic taxon should be plantae")
        XCTAssertNil(ochreSeaStarTaxon.iconicTaxon(), "ochre sea star should not have an iconic taxon within seek")
    }
    
    func testIconicTaxonImages() {
        XCTAssertEqual(silkMothTaxon.iconicImageName(), "icn-iconic-taxa-insects", "silk moth iconic taxon image name should be icn-iconic-taxa-insects")
        XCTAssertNotNil(UIImage(named: silkMothTaxon.iconicImageName()!), "silk moth iconic taxon image should exist")
        
        XCTAssertEqual(epidendrumSecundumTaxon.iconicImageName(), "icn-iconic-taxa-plants", "epidendrum secundum iconic taxon name should be icn-iconic-taxa-plants")
        XCTAssertNotNil(UIImage(named: epidendrumSecundumTaxon.iconicImageName()!), "epidendrum secundum iconic taxon image should exist")
        
        XCTAssertNil(ochreSeaStarTaxon.iconicImageName(), "ochre sea star should not have an iconic taxon image name (within seek)")
    }
}
