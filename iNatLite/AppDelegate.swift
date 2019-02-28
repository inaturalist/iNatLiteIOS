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


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        if let font = UIFont(name: "Whitney-Medium", size: 20) {
            UINavigationBar.appearance().titleTextAttributes = [
                NSAttributedString.Key.font: font
            ]
        }
        if let font = UIFont(name: "Whitney-Medium", size: 18) {
            UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
        }
        
        let dbMigrationKey = "HasMigratedDatabaseSeek1"
        if (!UserDefaults.standard.bool(forKey: dbMigrationKey)) {
            // copy the realm database from this shared container
            // back out to the default location
            if let directory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppDelegate.appGroupId) {
                
                let containerFileUrl = directory.appendingPathComponent("db.realm")
                let fm = FileManager.default
                if fm.fileExists(atPath: containerFileUrl.path) {
                    let realmConfig = RLMRealmConfiguration.default()
                    if let defaultFileUrl = realmConfig.fileURL {
                        do {
                            try fm.moveItem(at: containerFileUrl, to: defaultFileUrl)
                            defer {
                                UserDefaults.standard.set(true, forKey: dbMigrationKey)
                                UserDefaults.standard.synchronize()
                            }
                        } catch { }
                    }
                }
            }
        }
        
        let photoMigrationKey = "HasMigratedPhotosSeek1"
        if (!UserDefaults.standard.bool(forKey: photoMigrationKey)) {
            // copy the users photos from this shared container
            // back out to the app documents directory
            let photoUuidStrings = ObservationRealm.allContainerImageUUIDs()
            let fm = FileManager.default
            for photoUuidString in photoUuidStrings {
                if let containerUrl = ObservationRealm.containerPathForUUID(photoUuidString),
                    let appUrl = ObservationRealm.appPathForUUID(photoUuidString)
                {
                    do {
                        try fm.moveItem(at: containerUrl, to: appUrl)
                    } catch { }
                }
            }
            
            UserDefaults.standard.set(true, forKey: photoMigrationKey)
            UserDefaults.standard.synchronize()
        }
        
        let migrationConfig = Realm.Configuration(
            schemaVersion: 4,
            migrationBlock: { migration, oldSchemaVersion in
                if (oldSchemaVersion < 4) {
                    // Nothing to do!
                }
        })
        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = migrationConfig
        
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

