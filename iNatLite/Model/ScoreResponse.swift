//
//  ScoreResponse.swift
//  iNatLite
//
//  Created by Alex Shepard on 2/16/18.
//  Copyright © 2018 iNaturalist. All rights reserved.
//

import Foundation

struct ScoreResponse: Decodable {
    let total_results: Int?
    let page: Int?
    let per_page: Int?
    
    let results: [TaxonScore]
}

struct TaxonScore: Decodable {
    let vision_score: Float?
    let frequency_score: Float?
    let combined_score: Float
    let taxon: Taxon
}
