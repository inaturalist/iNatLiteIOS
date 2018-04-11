//
//  FixtureHelper.swift
//  iNatLiteTests
//
//  Created by Alex Shepard on 4/11/18.
//  Copyright © 2018 iNaturalist. All rights reserved.
//

@testable import iNatLite
import UIKit

class FixtureHelper: NSObject {
    class func imageFromFixture() -> UIImage? {
        if let path = Bundle(for: ChallengeResultsViewControllerTests.self).path(forResource: "IMG_0766", ofType: "jpg") {
            return UIImage(contentsOfFile: path)
        } else {
            return nil
        }
    }
    
    class func soldierFlyTaxon() -> Taxon? {
        return taxonFixtureWithId(357883)
    }
    
    class func silkMothTaxon() -> Taxon? {
        return taxonFixtureWithId(50913)
    }
    
    // this taxon has no common name
    class func epidendrumSecundumTaxon() -> Taxon? {
        return taxonFixtureWithId(130068)
    }
    
    internal class func taxonFixtureWithId(_ taxonId: Int) -> Taxon? {
        if let path = Bundle(for: ChallengeResultsViewControllerTests.self).path(forResource: "\(taxonId)", ofType: "json") {
            let url = URL(fileURLWithPath: path)
            let data = try! Data(contentsOf: url)
            let decoded = try! JSONDecoder().decode(TaxaResponse.self, from: data)
            if let results = decoded.results, results.count == 1 {
                return results.first
            }
        }
        return nil
    }
}
