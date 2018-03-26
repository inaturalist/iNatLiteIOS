//
//  BoundingBox.swift
//  iNatLite
//
//  Created by Alex Shepard on 2/23/18.
//  Copyright © 2018 iNaturalist. All rights reserved.
//

import Foundation
import MapKit

struct BoundingBox: Decodable {
    let swlat: Double
    let swlng: Double
    let nelat: Double
    let nelng: Double
    
    func mapRect() -> MKMapRect {
        let sw = CLLocationCoordinate2D(latitude: swlat, longitude: swlng)
        let ne = CLLocationCoordinate2D(latitude: nelat, longitude: nelng)
        
        let p1 = MKMapPointForCoordinate(sw)
        let p2 = MKMapPointForCoordinate(ne)
        return MKMapRectMake(fmin(p1.x,p2.x), fmin(p1.y,p2.y), fabs(p1.x-p2.x), fabs(p1.y-p2.y))
    }
}
