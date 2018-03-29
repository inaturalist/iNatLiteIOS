//
//  AppDelegate.swift
//  iNatLite
//
//  Created by Alex Shepard on 2/14/18.
//  Copyright © 2018 iNaturalist. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    static let appGroupId = "group.org.inaturalist.CardsSharing"

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        if let font = UIFont(name: "Whitney-Medium", size: 20) {
            UINavigationBar.appearance().titleTextAttributes = [
                NSAttributedStringKey.font: font
            ]
        }
        if let font = UIFont(name: "Whitney-Medium", size: 18) {
            UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedStringKey.font: font], for: .normal)
        }
        
        // put the realm database in a shared container so it can eventually be read by other iNaturalist apps
        if let directory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppDelegate.appGroupId) {
            
            
            let migrationConfig = Realm.Configuration(
                // Set the new schema version. This must be greater than the previously used
                // version (if you've never set a schema version before, the version is 0).
                schemaVersion: 4,
                
                // Set the block which will be called automatically when opening a Realm with
                // a schema version lower than the one set above
                migrationBlock: { migration, oldSchemaVersion in
                    // We haven’t migrated anything yet, so oldSchemaVersion == 0
                    if (oldSchemaVersion < 4) {
                        // Nothing to do!
                        // Realm will automatically detect new properties and removed properties
                        // And will update the schema on disk automatically
                    }
            })
            // Tell Realm to use this new configuration object for the default Realm
            Realm.Configuration.defaultConfiguration = migrationConfig

            let config = RLMRealmConfiguration.default()
            config.fileURL = directory.appendingPathComponent("db.realm")
            RLMRealmConfiguration.setDefault(config)
        }
        
        setupBadges()
        
        return true
    }



    func setupBadges() {
        
        let realm = try! Realm()
        var badgesDict: NSDictionary?
        if let path = Bundle.main.path(forResource: "Badges", ofType: "plist") {
            badgesDict = NSDictionary(contentsOfFile: path)
        }
        
        if let badgesDict = badgesDict {
            for (_, badgeDict) in badgesDict {
                if let badgeDict = badgeDict as? Dictionary<String, Any> {
                    let badge = BadgeRealm()
                    if let name = badgeDict["Name"] as? String {
                        badge.name = name
                    }
                    if let iconicTaxonName = badgeDict["IconicTaxon"] as? String {
                        badge.iconicTaxonName = iconicTaxonName
                    }
                    if let iconicTaxonId = badgeDict["IconicTaxonId"] as? Int {
                        badge.iconicTaxonId = iconicTaxonId
                    }
                    if let count = badgeDict["Count"] as? Int {
                        badge.count = count
                    }
                    if let earnedIconName = badgeDict["EarnedIcon"] as? String {
                        badge.earnedIconName = earnedIconName
                    }
                    if let unearnedIconName = badgeDict["UnearnedIcon"] as? String {
                        badge.unearnedIconName = unearnedIconName
                    }
                    if let infoText = badgeDict["InfoText"] as? String {
                        badge.infoText = infoText
                    }
                    if let index = badgeDict["Index"] as? Int {
                        badge.index = index
                    }
                    
                    // realm will clobber any set values here
                    if let prevBadge = realm.object(ofType: BadgeRealm.self, forPrimaryKey: badge.name) {
                        badge.earned = prevBadge.earned
                        badge.earnedDate = prevBadge.earnedDate
                    }
                    
                    try! realm.write {
                        realm.add(badge, update: true)
                    }
                }
            }
        }
    }
}

