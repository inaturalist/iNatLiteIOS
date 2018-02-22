//
//  ObservationRealm.swift
//  iNatLite
//
//  Created by Alex Shepard on 2/19/18.
//  Copyright © 2018 iNaturalist. All rights reserved.
//

import UIKit
import RealmSwift

class ObservationRealm: Object {
    override static func primaryKey() -> String? {
        return "uuidString"
    }
    
    @objc dynamic var uuidString: String = UUID().uuidString
    @objc dynamic var taxonId: Int = 0
    @objc dynamic var date: Date?

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
}
