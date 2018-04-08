//
//  Place.swift
//  iNatLite
//
//  Created by Alex Shepard on 2/14/18.
//  Copyright © 2018 iNaturalist. All rights reserved.
//

import Foundation

struct Place: Decodable {
    let id: Int
    let name: String
    
    var display_name: String?
    var admin_level: Int?
    var place_type: Int?
    
    var bounding_box_geojson: BBox?    
}

extension Place {
    struct Fixed {
        static let UnitedStates = Place(id: 1, name: "United States", display_name: "USA", admin_level: 0, place_type: 12, bounding_box_geojson: BBox(coordinates:[[[-179.231086,18.86546],[-179.231086,71.441059],[179.859681,71.441059],[179.859681,18.86546],[-179.231086,18.86546]]], type: "Polygon"))
    }
}

struct BBox: Decodable {
    // this feels brittle
    let coordinates: [[[Float]]]?
    let type: String?
}

