//
//  Histogram.swift
//  iNatLite
//
//  Created by Alex Shepard on 2/23/18.
//  Copyright © 2018 iNaturalist. All rights reserved.
//

import Foundation

struct Histogram: Decodable {
    let month_of_year: [String: Int]
}
