//
//  BadgesViewController.swift
//  iNatLite
//
//  Created by Alex Shepard on 2/14/18.
//  Copyright © 2018 iNaturalist. All rights reserved.
//

import UIKit
import RealmSwift
import FontAwesomeKit

private let badgeCellId = "BadgeCell"

class BadgesViewController: UICollectionViewController {
    
    var badges: Results<BadgeRealm>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.backBarButtonItem?.title = " "
        self.collectionView?.contentInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        
        let nib = UINib(nibName: "BadgeCell", bundle: Bundle.main)
        self.collectionView?.register(nib, forCellWithReuseIdentifier: badgeCellId)
        
        let realm = try! Realm()
        badges = realm.objects(BadgeRealm.self).sorted(byKeyPath: "index")
        
        if let badges = badges {
            let earned = badges.filter("earned == true")
            if earned.count == 0 {
                self.title = "No Badges Earned"
            } else if earned.count == 1 {
                self.title = "1 Badge Earned!"
            } else {
                self.title = "\(earned.count) Badges Earned!"
            }
        }
        
        self.collectionView?.reloadData()
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let badges = self.badges {
            return badges.count
        } else {
            return 0
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: badgeCellId, for: indexPath) as! BadgeCell
    
        if let badges = self.badges {
            let badge = badges[indexPath.item]
            cell.label?.text = badge.name
            cell.label?.textColor = UIColor.INat.BadgeNameText
            if badge.earned {
                if let badgeIconName = badge.earnedIconName {
                    cell.imageView?.image = UIImage(named: badgeIconName)
                }
            } else {
                if let badgeIconName = badge.unearnedIconName {
                    cell.imageView?.image = UIImage(named: badgeIconName)
                }
            }
        }
    
        return cell
    }

    // MARK: UICollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // show alert
        if let badges = self.badges {
            let badge = badges[indexPath.item]
            
            if let info = badge.infoText            {
                let title = badge.name
                var msg = info
                if let earnedDateStr = badge.relativeEarnedDateString {
                    msg.append(" You earned this badge \(earnedDateStr.lowercased()).")
                }
                let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Got it!", style: .default, handler: nil))
                present(alert, animated: true)
            }

            
            if let msg = badge.infoText {
                let title = badge.name
                
                let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Got it!", style: .default, handler: nil))
                present(alert, animated: true)
            }
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension BadgesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let tilesPerRow = 3
        let width = (collectionView.frame.size.width / CGFloat(tilesPerRow)) - 21
        return CGSize(width: width, height: width * 1.3)
    }
 
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 5.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 5.0
    }
}

