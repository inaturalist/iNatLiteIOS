//
//  NearbyPlaceResponse.swift
//  iNatLite
//
//  Created by Alex Shepard on 2/14/18.
//  Copyright © 2018 iNaturalist. All rights reserved.
//

import Foundation

struct PlaceNearbyResponse: Decodable {
    let total_results: Int?
    let page: Int?
    let per_page: Int?
    
    let results: PlaceNearbyResults?
}

struct PlaceNearbyResults: Decodable {
    let standard: [Place]?
    let community: [Place]?
}
