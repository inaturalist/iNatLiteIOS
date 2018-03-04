//
//  BoundingBoxResponse.swift
//  iNatLite
//
//  Created by Alex Shepard on 2/23/18.
//  Copyright © 2018 iNaturalist. All rights reserved.
//

import Foundation

struct BoundingBoxResponse: Decodable {
    let total_results: Int?
    let total_bounds: BoundingBox?
}
