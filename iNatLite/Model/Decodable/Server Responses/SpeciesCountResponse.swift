//
//  SpeciesCountResponse.swift
//  iNatLite
//
//  Created by Alex Shepard on 2/14/18.
//  Copyright © 2018 iNaturalist. All rights reserved.
//

import Foundation

struct SpeciesCountResponse: Decodable {
    let total_results: Int?
    let page: Int?
    let per_page: Int?
    
    let results: [SpeciesCount]?
}

struct SpeciesCount: Decodable {
    let count: Int
    let taxon: Taxon
}

extension SpeciesCount: Equatable {
    static func == (lhs: SpeciesCount, rhs: SpeciesCount) -> Bool {
        return lhs.taxon == rhs.taxon
    }
}
