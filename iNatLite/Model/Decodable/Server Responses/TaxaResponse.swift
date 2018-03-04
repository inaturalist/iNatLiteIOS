//
//  TaxaResponse.swift
//  iNatLite
//
//  Created by Alex Shepard on 2/23/18.
//  Copyright © 2018 iNaturalist. All rights reserved.
//

import Foundation

struct TaxaResponse: Decodable {
    let total_results: Int?
    let page: Int?
    let per_page: Int?
    
    let results: [Taxon]?
}
