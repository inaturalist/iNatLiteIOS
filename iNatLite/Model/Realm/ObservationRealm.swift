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
    
    var coordinate: CLLocationCoordinate2D? {
        get {
            if latitude != 0.0, longitude != 0.0 {
                let coord = CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
                if CLLocationCoordinate2DIsValid(coord) {
                    return coord
                } else {
                    return nil
                }
            } else {
                return nil
            }
        }
    }
    
    var uuid: UUID? {
        get {
            if let uuid = UUID(uuidString: self.uuidString) {
                return uuid
            } else {
                return nil
            }
        }
    }
    
    func appPathForImage() -> URL? {
        return ObservationRealm.self.appPathForUUID(uuidString)
    }
    
    class func allContainerImageUUIDs() -> [String] {
        var uuids = [String]()
        
        if let directory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppDelegate.appGroupId) {
            let largeDirectory = directory.appendingPathComponent("large")
            
            do {
                let contents = try FileManager.default.contentsOfDirectory(atPath: largeDirectory.path)
                uuids.append(contentsOf: contents)
            } catch { }
        }
        
        return uuids
    }
    
    class func containerPathForUUID(_ uuidString: String) -> URL? {
        if let containerDir = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppDelegate.appGroupId) {
            let largeDirUrl = containerDir.appendingPathComponent("large")
            do {
                if !FileManager.default.fileExists(atPath: largeDirUrl.path) {
                    try FileManager.default.createDirectory(at: largeDirUrl, withIntermediateDirectories: true, attributes: nil)
                }
                return largeDirUrl.appendingPathComponent(uuidString)
            } catch {
                return nil
            }
            
        } else {
            return nil
        }
    }
    
    class func appPathForUUID(_ uuidString: String) -> URL? {
        if let documentDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
            do {
                let directoryUrl = URL(fileURLWithPath: documentDir)
                let largeDirUrl = directoryUrl.appendingPathComponent("large")
                if !FileManager.default.fileExists(atPath: largeDirUrl.path) {
                    try FileManager.default.createDirectory(at: largeDirUrl, withIntermediateDirectories: false, attributes: nil)
                }
                return largeDirUrl.appendingPathComponent(uuidString)
            } catch {
                return nil
            }
        } else {
            return nil
        }
    }
    
    
    func pathForImage() -> URL? {
        return appPathForImage()
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
