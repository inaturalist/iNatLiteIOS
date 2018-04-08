//
//  YourCollectionViewController.swift
//  iNatLite
//
//  Created by Alex Shepard on 2/14/18.
//  Copyright © 2018 iNaturalist. All rights reserved.
//

import UIKit
import RealmSwift
import FontAwesomeKit

private let speciesCellId = "SpeciesCellId"
private let badgeCellId = "BadgeCell"
private let myCollectionHeaderId = "MyCollectionHeader"
// collection view datasource uses introspection to find out if a header is needed
// since we're using a shared datasource for two collection views, one with a header
// and one without, we need to give a fake empty zero size header for the second
private let emptyHeaderId = "EmptyHeader"

class YourCollectionViewController: UIViewController {
    
    @IBOutlet var collectionView: UICollectionView?
    @IBOutlet var badgesBackground: UIView?
    
    var observations: Results<ObservationRealm>?
    var badges: Results<BadgeRealm>?
    
    @objc func aboutTapped() {
        self.performSegue(withIdentifier: "segueToAbout", sender: nil)
    }
    
    @objc func viewAllBadgesTapped() {
        self.performSegue(withIdentifier: "segueToBadges", sender: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let speciesNib = UINib(nibName: "SpeciesCollectionView", bundle: Bundle.main)
        collectionView?.register(speciesNib, forCellWithReuseIdentifier: speciesCellId)
        let badgeNib = UINib(nibName: "BadgeCell", bundle: Bundle.main)
        collectionView?.register(badgeNib, forCellWithReuseIdentifier: badgeCellId)

        let realm = try! Realm()
        observations = realm.objects(ObservationRealm.self)
        let badgeSorts = [SortDescriptor(keyPath: "earnedDate", ascending: false),
                          SortDescriptor(keyPath: "index", ascending: true)]
        badges = realm.objects(BadgeRealm.self).sorted(by: badgeSorts)
        
        let aboutTitle = NSLocalizedString("About", comment: "Button to go to about screen")
        let aboutButton = UIBarButtonItem(title: aboutTitle, style: .plain, target: self, action: #selector(YourCollectionViewController.aboutTapped))
        self.navigationItem.rightBarButtonItem = aboutButton

        badgesBackground?.backgroundColor = UIColor.INat.MyCollectionBadgesHeaderBackground
        view.backgroundColor = .white
        self.collectionView?.backgroundColor = .clear
        self.collectionView?.backgroundView = nil
        
        if let badgesBackground = self.badgesBackground {
            let filteredConstraints = badgesBackground.constraints.filter { $0.identifier == "badgesBackgroundHeight" }
            if let badgesHeight = filteredConstraints.first, let cv = self.collectionView {
                let tilesPerRow: CGFloat = 3
                let badgeCellHeight: CGFloat = ((cv.frame.size.width / CGFloat(tilesPerRow)) - 21) * 1.3
                let padding: CGFloat = 25
                let badgeHeader: CGFloat = 50.0
                if let badges = badges, badges.count > 0 {
                    badgesHeight.constant = badgeHeader + padding + badgeCellHeight + padding
                } else {
                    badgesHeight.constant = badgeHeader + padding + padding
                }
            }
            self.view.setNeedsLayout()
        }
            
            
        collectionView?.reloadData()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToSpeciesDetails",
            let dest = segue.destination as? SpeciesDetailViewController,
            let observation = sender as? ObservationRealm
        {
            dest.observation = observation
            dest.seen = true
        }
    }
}

// MARK: - UICollectionViewDataSource
extension YourCollectionViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            // your badges
            if let badges = self.badges {
                return min(badges.count, 3)
            } else {
                return 0
            }
        } else {
            // your collection
            if let observations = self.observations {
                return observations.count
            } else {
                return 0
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 {
            // your recent badges
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: badgeCellId, for: indexPath) as! BadgeCell
            
            cell.contentView.backgroundColor = UIColor.INat.MyCollectionBadgesHeaderBackground
            
            if let badges = self.badges {
                let badge = badges[indexPath.item]
                cell.label?.text = badge.localizedName
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
        } else {
            // your collection
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: speciesCellId, for: indexPath) as! SpeciesCollectionViewCell
            
            cell.nameScrim?.backgroundColor = UIColor.INat.MyCollectionChicletLabelBackground
            cell.nameLabel?.textColor = UIColor.black
            
            if let observations = self.observations {
                let observation = observations[indexPath.item]
                // configure for observation
                if let taxon = observation.taxon {
                    cell.nameLabel?.text = taxon.anyNameCapitalized
                    if let photo = taxon.defaultPhoto,
                        let urlString = photo.mediumUrl,
                        let url = URL(string: urlString)
                    {
                        cell.photoView?.setImage(url: url)
                    }
                }
            }
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: myCollectionHeaderId, for: indexPath) as! MyCollectionHeaderView

        if indexPath.section == 0 {
            // badges
            if let badges = self.badges {
                if badges.filter("earned == TRUE").count > 0 {
                    view.titleLabel?.text = NSLocalizedString("Recent Badges", comment: "Title for badges section of my collection screen, if the user has earned any badges.")
                } else {
                    view.titleLabel?.text = NSLocalizedString("Badges", comment: "Title for badges section of my collection screen, if the user hasn't earned any badges.")
                }
            }
            view.moreButton?.setTitle(NSLocalizedString("View All", comment: "Button to view all badges, seen next to the most recently earned badges"), for: .normal)
            view.moreButton?.addTarget(self, action: #selector(YourCollectionViewController.viewAllBadgesTapped), for: .touchUpInside)
            view.moreButton?.isHidden = false
            view.backgroundColor = UIColor.INat.MyCollectionBadgesHeaderBackground
        } else {
            // my collection
            if let observations = self.observations {
                view.titleLabel?.text = String(format: NSLocalizedString("Species You've Seen (%d)", comment: "Title for my collection section - the number is the count of species seen by the user"), observations.count)
            }
            view.moreButton?.isHidden = true
            view.backgroundColor = .white
        }
        
        return view

    }
}

// MARK: - UICollectionViewDelegate
extension YourCollectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            // show alert
            if let badges = self.badges {
                let badge = badges[indexPath.item]
                if let localizedInfo = badge.localizedInfoText
                {
                    let title = badge.localizedName
                    
                    var msg = localizedInfo
                    if badge.earned {
                        msg.append(" ")
                        msg.append(NSLocalizedString("You earned this badge.", comment: "Message in a notice that indicates the user has earned a badge."))
                    }

                    let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
                    let gotitButtonTitle = NSLocalizedString("Got it!", comment: "OK button after informational alert")
                    alert.addAction(UIAlertAction(title: gotitButtonTitle, style: .default, handler: nil))
                    present(alert, animated: true)
                }
            }
        } else {
            // push species details
            if let observations = self.observations {
                let observation = observations[indexPath.item]
                self.performSegue(withIdentifier: "segueToSpeciesDetails", sender: observation)
            }
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension YourCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let tilesPerRow = 3
        let width = (collectionView.frame.size.width / CGFloat(tilesPerRow)) - 21
        return CGSize(width: width, height: width * 1.3)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSize(width: collectionView.bounds.size.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsetsMake(0, 16, 16, 16)
    }
}

