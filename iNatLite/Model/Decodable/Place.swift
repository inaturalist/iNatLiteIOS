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
    
    var place_type_name: String? {
        // https://github.com/inaturalist/inaturalist/blob/0a11c5bf322e742d25e218cb9642aa8c2bfc6f99/app/models/place.rb#L98
        let place_type_names = [
            0 : "Undefined",
            1 : "Building",
            2 : "Street Segment",
            3 : "Nearby Building",
            5 : "Intersection",
            6 : "Street",
            7 : "Town",
            8 : "State",
            9 : "County",
            10 : "Local Administrative Area",
            11 : "Postal Code",
            12 : "Country",
            13 : "Island",
            14 : "Airport",
            15 : "Drainage",
            16 : "Land Feature",
            17 : "Miscellaneous",
            18 : "Nationality",
            19 : "Supername",
            20 : "Point of Interest",
            21 : "Region",
            22 : "Suburb",
            23 : "Sports Team",
            24 : "Colloquial",
            25 : "Zone",
            26 : "Historical State",
            27 : "Historical County",
            29 : "Continent",
            31 : "Time Zone",
            32 : "Nearby Intersection",
            33 : "Estate",
            35 : "Historical Town",
            36 : "Aggregate",
            
            100 : "Open Space",
            101 : "Territory",
            102 : "District",
            103 : "Province",
            
            1000 : "Municipality",
            1001 : "Parish",
            1002 : "Department Segment",
            1003 : "City Building",
            1004 : "Commune",
            1005 : "Governorate",
            1006 : "Prefecture",
            1007 : "Canton",
            1008 : "Republic",
            1009 : "Division",
            1010 : "Subdivision",
            1011 : "Village block",
            1012 : "Sum",
            1013 : "Unknown",
            1014 : "Shire",
            1015 : "Prefecture City",
            1016 : "Regency",
            1017 : "Constituency",
            1018 : "Local Authority",
            1019 : "Poblacion",
            1020 : "Delegation",
            ]
        
        if let type = self.place_type, let name = place_type_names[type] {
            return name
        } else {
            return nil
        }
    }
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

