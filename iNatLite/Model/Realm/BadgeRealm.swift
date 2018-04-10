//
//  BadgeRealm.swift
//  iNatLite
//
//  Created by Alex Shepard on 2/25/18.
//  Copyright © 2018 iNaturalist. All rights reserved.
//

import UIKit
import RealmSwift

class BadgeRealm: Object {
    override static func primaryKey() -> String? {
        return "name"
    }
    
    @objc dynamic var name: String = ""
    @objc dynamic var earned: Bool = false
    @objc dynamic var earnedDate: Date?
    @objc dynamic var iconicTaxonName: String?
    @objc dynamic var iconicTaxonId: Int = 0
    @objc dynamic var count: Int = 0
    @objc dynamic var earnedIconName: String?
    @objc dynamic var unearnedIconName: String?
    @objc dynamic var infoText: String?
    @objc dynamic var index: Int = 0
    
    var relativeEarnedDateString: String? {
        get {
            let fmt = DateFormatter()
            fmt.doesRelativeDateFormatting = true
            fmt.dateStyle = .medium
            fmt.timeStyle = .none
            if let date = self.earnedDate {
                return fmt.string(from: date)
            } else {
                return nil
            }
        }
    }
    
    var localizedName: String {
        get {
            return NSLocalizedString(self.name, tableName: "LocalizableBadges.strings", bundle: Bundle.main, value: self.name, comment: "")
        }
    }
    
    var localizedInfoText: String? {
        get {
            if let infoText = self.infoText {
                return NSLocalizedString(infoText, tableName: "LocalizableBadges.strings", bundle: Bundle.main, value: infoText, comment: "")
            } else {
                return nil
            }
        }
    }

    
}
