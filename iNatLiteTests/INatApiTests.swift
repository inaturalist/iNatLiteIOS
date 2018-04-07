//
//  INatApiTests.swift
//  iNatLiteTests
//
//  Created by Alex Shepard on 4/7/18.
//  Copyright © 2018 iNaturalist. All rights reserved.
//

import XCTest
import CoreLocation

@testable import iNatLite

class INatApiTests: XCTestCase {
    
    var api: INatApi!
    
    override func setUp() {
        api = INatApi()
    }
    
    func testPostParamsForCoodinate() {
        let coordinate = CLLocationCoordinate2D(latitude: 37, longitude: 102)
        let date = Date()
        let badCoordinate = kCLLocationCoordinate2DInvalid
        
        let locationDict = ["lat": "37.0", "lng": "102.0"]
        let dateDict = ["observed_on": "\(date.timeIntervalSince1970)"]
        let fullDict = locationDict.merging(dateDict, uniquingKeysWith: { (first, _) in first })
        
        XCTAssertTrue(api.postParamsForCoordinate(nil, date: nil).isEmpty,
                      "with no coord and no date, the api post params should be empty")
        XCTAssertTrue(api.postParamsForCoordinate(badCoordinate, date: nil).isEmpty,
                      "with bad coord and no date, the api post params should be empty")
        XCTAssertEqual(api.postParamsForCoordinate(coordinate, date: nil), locationDict,
                       "with good coord and date, the post params should be \(locationDict)")
        XCTAssertEqual(api.postParamsForCoordinate(nil, date: date), dateDict,
                       "with no coord and a date, the post params should be \(dateDict)")
        XCTAssertEqual(api.postParamsForCoordinate(coordinate, date: date), fullDict,
                       "with good coord and date, the post params should be \(fullDict)")
    }
    
    func testPlaceIdSpeciesCountsUrl() {
        let emptyUrl = URL(string: "https://api.inaturalist.org/v1/observations/species_counts?threatened=false&verifiable=true&oauth_application_id=2,3&hrank=species&include_only_vision_taxa=true&not_in_list_id=945029")!
        let iconicOnlyUrl = URL(string: "https://api.inaturalist.org/v1/observations/species_counts?threatened=false&verifiable=true&oauth_application_id=2,3&hrank=species&include_only_vision_taxa=true&not_in_list_id=945029&taxon_id=13")!
        let oneMonthOnlyUrl = URL(string: "https://api.inaturalist.org/v1/observations/species_counts?threatened=false&verifiable=true&oauth_application_id=2,3&hrank=species&include_only_vision_taxa=true&not_in_list_id=945029&month=1")!
        let twoMonthsOnlyUrl = URL(string: "https://api.inaturalist.org/v1/observations/species_counts?threatened=false&verifiable=true&oauth_application_id=2,3&hrank=species&include_only_vision_taxa=true&not_in_list_id=945029&month=1,2")!
        let threeMonthsOnlyUrl = URL(string: "https://api.inaturalist.org/v1/observations/species_counts?threatened=false&verifiable=true&oauth_application_id=2,3&hrank=species&include_only_vision_taxa=true&not_in_list_id=945029&month=1,2,3")!
        let placeParamOnlyUrl = URL(string: "https://api.inaturalist.org/v1/observations/species_counts?threatened=false&verifiable=true&oauth_application_id=2,3&hrank=species&include_only_vision_taxa=true&not_in_list_id=945029&place_id=13")
        let allUrl = URL(string: "https://api.inaturalist.org/v1/observations/species_counts?threatened=false&verifiable=true&oauth_application_id=2,3&hrank=species&include_only_vision_taxa=true&not_in_list_id=945029&lat=37.0&lng=127.0&month=1,2,3&taxon_id=13")

        let placeIdParam = URLQueryItem(name: "place_id", value: "13")
        let locationParams = [URLQueryItem(name: "lat", value: "37.0"),
                              URLQueryItem(name: "lng", value: "127.0")]
        
        XCTAssertEqual(api.speciesCountsUrlWithPlaceParams([], months: [], iconicTaxonId: nil), emptyUrl)
        XCTAssertEqual(api.speciesCountsUrlWithPlaceParams([], months: [], iconicTaxonId: 13), iconicOnlyUrl)
        XCTAssertEqual(api.speciesCountsUrlWithPlaceParams([], months: [1], iconicTaxonId: nil), oneMonthOnlyUrl)
        XCTAssertEqual(api.speciesCountsUrlWithPlaceParams([], months: [1,2], iconicTaxonId: nil), twoMonthsOnlyUrl)
        XCTAssertEqual(api.speciesCountsUrlWithPlaceParams([], months: [1,2,3], iconicTaxonId: nil), threeMonthsOnlyUrl)
        XCTAssertEqual(api.speciesCountsUrlWithPlaceParams([placeIdParam], months: [], iconicTaxonId: nil), placeParamOnlyUrl)
        XCTAssertEqual(api.speciesCountsUrlWithPlaceParams(locationParams, months: [1,2,3], iconicTaxonId: 13), allUrl)
    }
}
