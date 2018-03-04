//
//  CLLocationCoordinate2D+INatLite.swift
//  iNatLite
//
//  Created by Alex Shepard on 3/4/18.
//  Copyright © 2018 iNaturalist. All rights reserved.
//

import Foundation
import CoreLocation

extension CLLocationCoordinate2D {
    func truncate(places : Int)-> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.latitude.truncate(places: places), longitude: self.longitude.truncate(places: places))
    }
}

extension CLLocationDegrees {
    func truncate(places : Int)-> CLLocationDegrees {
        return CLLocationDegrees(floor(pow(10.0, CLLocationDegrees(places)) * self)/pow(10.0, CLLocationDegrees(places)))
    }
}

