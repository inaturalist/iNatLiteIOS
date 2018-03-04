//
//  BoundingBox.swift
//  iNatLite
//
//  Created by Alex Shepard on 2/23/18.
//  Copyright © 2018 iNaturalist. All rights reserved.
//

import Foundation

struct BoundingBox: Decodable {
    let swlat: Double
    let swlng: Double
    let nelat: Double
    let nelng: Double
}
