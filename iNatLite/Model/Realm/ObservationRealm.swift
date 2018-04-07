//
//  ObservationRealm.swift
//  iNatLite
//
//  Created by Alex Shepard on 2/19/18.
//  Copyright © 2018 iNaturalist. All rights reserved.
//

import UIKit
import RealmSwift
import CoreLocation
import MapKit

class ObservationRealm: Object {
    override static func primaryKey() -> String? {
        return "uuidString"
    }
    
    @objc dynamic var uuidString: String = UUID().uuidString
    @objc dynamic var date: Date?
    @objc dynamic var taxon: TaxonRealm?
    
    @objc dynamic var latitude: Float = 0.0
    @objc dynamic var longitude: Float = 0.0
    @objc dynamic var placeName: String?
    
    var uuid: UUID? {
        get {
            if let uuid = UUID(uuidString: self.uuidString) {
                return uuid
            } else {
                return nil
            }
        }
    }
    
    func pathForImage() -> URL? {
        if let directory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppDelegate.appGroupId) {
            
            let largePath = directory.appendingPathComponent("large")
            if !FileManager.default.fileExists(atPath: largePath.path) {
                try! FileManager.default.createDirectory(at: largePath, withIntermediateDirectories: false, attributes: nil)
            }
            return largePath.appendingPathComponent(uuidString)
        } else {
            return nil
        }
    }
    
    var dateString: String? {
        get {
            let fmt = DateFormatter()
            fmt.dateStyle = .medium
            fmt.timeStyle = .none
            if let date = self.date {
                return fmt.string(from: date)
            } else {
                return nil
            }
        }
    }
    
    var relativeDateString: String? {
        get {
            let fmt = DateFormatter()
            fmt.doesRelativeDateFormatting = true
            fmt.dateStyle = .medium
            fmt.timeStyle = .none
            if let date = self.date {
                return fmt.string(from: date)
            } else {
                return nil
            }
        }
    }
}

extension ObservationRealm: MKAnnotation {
    var coordinate: CLLocationCoordinate2D {
        get {
            if latitude != 0.0, longitude != 0.0 {
                let coord = CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude),
                                                   longitude: CLLocationDegrees(longitude))
                if CLLocationCoordinate2DIsValid(coord) {
                    return coord
                } else {
                    return kCLLocationCoordinate2DInvalid
                }
            } else {
                // nothing happens on null island
                return kCLLocationCoordinate2DInvalid
            }
        }
    }
}
