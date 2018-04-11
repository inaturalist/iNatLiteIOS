//
//  ChallengeResultsViewController.swift
//  iNatLite
//
//  Created by Alex Shepard on 2/16/18.
//  Copyright © 2018 iNaturalist. All rights reserved.
//

import UIKit
import FontAwesomeKit
import RealmSwift
import CoreLocation

private let titleCellId = "ResultsTitleCell"
private let dividerCellId = "ResultsDividerCell"
private let singleImageCellId = "ResultsSingleImageCell"
private let dualImageCellId = "ResultsDualImageCell"
private let actionCellId = "ResultsActionCell"


protocol ChallengeResultsDelegate: NSObjectProtocol {
    func addedToCollection(_ taxon: Taxon)
}

class ChallengeResultsViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView?
    @IBOutlet var gradientBackground: RadialGradientView?
    @IBOutlet var activitySpinner: UIActivityIndicatorView?
    @IBOutlet var noticeLabel: UILabel?
    
    var imageFromUser: UIImage?
    var takenDate: Date?
    var takenLocation: CLLocation?
    
    var targetTaxon: Taxon?
    var resultScore: TaxonScore?
    var resultsLoaded = false
    
    var commonAncestor: TaxonScore?
    
    var observations: Results<ObservationRealm>?    
    var seenTaxaIds: [Int] {
        get {
            if let observations = self.observations {
                return observations.filter { return $0.taxon != nil }.map { return $0.taxon!.id }
            } else {
                return [Int]()
            }
        }
    }
    
    weak var delegate: ChallengeResultsDelegate?
    
    func loadResults() {
        if let imageFromUser = self.imageFromUser {
            
            self.activitySpinner?.isHidden = false
            self.activitySpinner?.startAnimating()

            INatApi().scoreImage(imageFromUser, coordinate: self.takenLocation?.coordinate, date: self.takenDate) { (response, error) in
                self.activitySpinner?.isHidden = true
                self.activitySpinner?.stopAnimating()

                if let error = error {
                    self.noticeLabel?.text = String(format: NSLocalizedString("Can't load computer vision suggestions: %@ Try again later.", comment: "error notice when we can't load a network request for suggestions. the string inserted is a detailed error message"), error.localizedDescription)
                    self.noticeLabel?.isHidden = false
                } else if let response = response {
                    for result in response.results {
                        if let target = self.targetTaxon,
                            target.id == result.taxon.id,
                            let score = result.combined_score,
                            score > 85
                        {
                            self.resultScore = result
                            break
                        } else if let score = result.combined_score,
                            score > 97
                        {
                            self.resultScore = result
                            break
                        }
                    }
                    self.commonAncestor = response.common_ancestor
                    self.resultsLoaded = true
                    self.activitySpinner?.isHidden = true
                    self.activitySpinner?.stopAnimating()
                    self.tableView?.reloadData()
                }
            }
        }
    }

    
    // MARK: - UIViewController lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let spinner = self.activitySpinner {
            spinner.transform = CGAffineTransform.init(scaleX: 3, y: 3)
        }

        // trick to hide extra lines after the tableview cells run out
        self.tableView?.tableFooterView = UIView()
        
        if let gradient = self.gradientBackground {
            gradient.insideColor = UIColor.INat.LighterDarkBlue
            gradient.outsideColor = UIColor.INat.DarkBlue
        }

        view.backgroundColor = UIColor.INat.LighterDarkBlue
        
        let realm = try! Realm()
        self.observations = realm.objects(ObservationRealm.self)
        
        self.loadResults()
    }

    
    // MARK: - UITableViewCell helpers
    
    func configureDividerCell(_ cell: ResultsDividerCell) {
        cell.backgroundColor = UIColor.clear
        cell.scrim?.backgroundColor = UIColor.white.withAlphaComponent(0.07)
        
        if let score = self.resultScore {
            if let target = self.targetTaxon {
                if target == score.taxon {
                    // you found your target
                    cell.dividerImageView?.image = UIImage(named: "icn-results-match")
                } else {
                    // you found something else
                    cell.dividerImageView?.image = UIImage(named: "icn-results-mismatch")
                }
            } else {
                cell.dividerImageView?.image = UIImage(named: "icn-results-match")
            }
        } else {
            if let _ = self.targetTaxon {
                cell.dividerImageView?.image = UIImage(named: "icn-results-mismatch")
            } else {
                cell.dividerImageView?.image = UIImage(named: "icn-results-unknown")
            }
        }
    }

    func configureTitleCell(_ cell: ResultsTitleCell) {
        cell.backgroundColor = UIColor.clear

        if let score = self.resultScore {
            if let target = self.targetTaxon {
                if target == score.taxon {
                    // you found your target
                    cell.title?.text = NSLocalizedString("It's a Match!", comment: "Title when the user has found the species they were challenged with.")
                    cell.subtitle?.text = String(format: NSLocalizedString("You saw a %@.", comment: "Notice telling the user what species they saw."), score.taxon.displayName)
                } else {
                    // you found something else
                    cell.title?.text = NSLocalizedString("Good Try!", comment: "Title when the user has found a different species than they one they were challenged with.")
                    cell.subtitle?.text = String(format: NSLocalizedString("However, this isn't a %@, it's a %@.", comment: "Notice telling the user that they've found a different species than the one they were challenged with. First subtitution is the target/challenge species, second substitution is the actual found species."), target.displayName, score.taxon.displayName)

                    cell.subtitle?.text = "However, this isn't a \(target.displayName), it's a \(score.taxon.displayName)."
                }
            } else {
                if self.seenTaxaIds.contains(score.taxon.id) {
                    cell.title?.text = NSLocalizedString("Deja Vu!", comment: "Title when the user has found a species that they've already seen.")
                    cell.subtitle?.text = String(format: NSLocalizedString("Looks like you already collected a %@.", comment: "Notice telling the user that they've already seen this species."), score.taxon.displayName)
                } else {
                    cell.title?.text = NSLocalizedString("Sweet!", comment: "Title when the user has found a new species (without having been given a challenge).")
                    cell.subtitle?.text = String(format: NSLocalizedString("You saw a %@.", comment: "Notice telling the user what species they saw."), score.taxon.displayName)
                }
            }
        } else {
            cell.title?.text = NSLocalizedString("Hrmmmmmm", comment: "Title when we can't figure out what species is in the user's photo.")
            if let ancestor = self.commonAncestor {
                cell.subtitle?.text = String(format: NSLocalizedString("We think this is a photo of %@, but we can't say for sure what species it is.", comment: "Notice when we have only a rough idea of what's in the user's photo."), ancestor.taxon.displayName)
            } else {
                cell.subtitle?.text = NSLocalizedString("We can't figure this one out. Please try some adjustments.", comment: "Notice when we have no idea what's in the user's photo.")
            }
        }
    }
    
    func configureImageCell(_ cell: ResultsSingleImageCell) {
        cell.backgroundColor = UIColor.white.withAlphaComponent(0.07)
        
        cell.userImageView?.image = self.imageFromUser
        cell.userLabel?.text = nil
    }
    
    func configureImageTaxonCell(_ cell: ResultsDualImageCell) {
        cell.backgroundColor = UIColor.white.withAlphaComponent(0.07)

        // left label
        if let score = self.resultScore {
            cell.leadingImageLabel?.text = String(format: NSLocalizedString("Your Photo:\n%@", comment: "Title of the user photo. The substition is the species name in their photo."), score.taxon.displayName)
        } else {
            cell.leadingImageLabel?.text = NSLocalizedString("Your Photo", comment: "Title of the user photo, when we don't have a species for it.")
        }

        // left photo is always user photo
        cell.leadingImageView?.image = self.imageFromUser
        
        // right label
        if let target = self.targetTaxon {
            cell.leadingImageLabel?.text = String(format: NSLocalizedString("Target Species:\n%@", comment: "Title of the target species photo. The substition is the target species name."), target.displayName)

            cell.trailingImageLabel?.text = "Target Species:\n\(target.displayName)"
        } else if let score = self.resultScore {
            cell.leadingImageLabel?.text = String(format: NSLocalizedString("Identified Species:\n%@", comment: "Title of the identified species photo. The substition is the identified species name."), score.taxon.displayName)
        }
        
        // right photo
        if let target = self.targetTaxon {
            // show the target taxon photo
            if let photo = target.default_photo,
                let urlString = photo.medium_url,
                let url = URL(string: urlString)
            {
                cell.trailingImageView?.setImage(url: url)
            }
        } else if let score = self.resultScore {
            // show the identified taxon photo
            if let photo = score.taxon.default_photo,
                let urlString = photo.medium_url,
                let url = URL(string: urlString)
            {
                cell.trailingImageView?.setImage(url: url)
            }
        }
    }
    
    func configureActionCell(_ cell: ResultsActionCell) {
        cell.backgroundColor = UIColor.clear

        if let result = self.resultScore {
            if self.seenTaxaIds.contains(result.taxon.id) {
                // already seen it
                if let observations = self.observations {
                    for observation in observations {
                        if let obsTaxon = observation.taxon, let obsDate = observation.dateString {
                            if obsTaxon.id == result.taxon.id {
                                cell.infoLabel?.text = String(format: NSLocalizedString("You collected a photo of a %@ on %@", comment: "Notice about when the user collected a species photo. First subtitution is the species name, second substitution is the locally formatted date."), obsTaxon.displayName)
                                cell.infoLabel?.textColor = UIColor.INat.SpeciesAddButton
                                
                                cell.actionButton?.setTitle(NSLocalizedString("OK", comment: "OK button title"), for: .normal)
                                cell.actionButton?.backgroundColor = UIColor.clear
                                cell.actionButton?.tintColor = UIColor.white
                                cell.actionButton?.layer.cornerRadius = 22
                                cell.actionButton?.layer.borderColor = UIColor.INat.Green.cgColor
                                cell.actionButton?.layer.borderWidth = 2.0
                                cell.actionButton?.clipsToBounds = true
                                cell.actionButton?.addTarget(self, action: #selector(ChallengeResultsViewController.okPressed), for: .touchUpInside)
                            }
                        }
                    }
                }
            } else {
                if let target = self.targetTaxon {
                    if target == result.taxon {
                        // show add to collection button
                        cell.infoLabel?.text = nil
                        cell.actionButton?.setTitle(NSLocalizedString("Add to Collection", comment: "add species to your collection button title"), for: .normal)
                        if let font = UIFont(name: "Riffic-Bold", size: 18) {
                            cell.actionButton?.titleLabel?.font = font
                        }
                        cell.actionButton?.backgroundColor = UIColor.INat.Green
                        cell.actionButton?.tintColor = UIColor.white
                        cell.actionButton?.layer.cornerRadius = 22
                        cell.actionButton?.clipsToBounds = true
                        cell.actionButton?.addTarget(self, action: #selector(ChallengeResultsViewController.addToCollection), for: .touchUpInside)
                    } else {
                        // show notice that they still need to collect it
                        cell.infoLabel?.text = "You still need to collect a \(result.taxon.displayName). Would you like to collect it now?"
                        cell.actionButton?.setTitle(NSLocalizedString("Add to Collection", comment: "add species to your collection button title"), for: .normal)
                        cell.actionButton?.backgroundColor = UIColor.clear
                        cell.actionButton?.tintColor = UIColor.white
                        cell.actionButton?.layer.cornerRadius = 22
                        cell.actionButton?.layer.borderColor = UIColor.INat.Green.cgColor
                        cell.actionButton?.layer.borderWidth = 2.0
                        cell.actionButton?.clipsToBounds = true
                        cell.actionButton?.addTarget(self, action: #selector(ChallengeResultsViewController.addToCollection), for: .touchUpInside)
                    }
                } else {
                    // show add to collection button
                    cell.infoLabel?.text = nil
                    cell.actionButton?.setTitle(NSLocalizedString("Add to Collection", comment: "add species to your collection button title"), for: .normal)
                    if let font = UIFont(name: "Riffic-Bold", size: 18) {
                        cell.actionButton?.titleLabel?.font = font
                    }
                    cell.actionButton?.backgroundColor = UIColor.INat.Green
                    cell.actionButton?.tintColor = UIColor.white
                    cell.actionButton?.layer.cornerRadius = 22
                    cell.actionButton?.clipsToBounds = true
                    cell.actionButton?.addTarget(self, action: #selector(ChallengeResultsViewController.addToCollection), for: .touchUpInside)
                }
            }
        } else {
            // show tips
            cell.infoLabel?.text = NSLocalizedString("Here are some photo tips:\nGet as close as possible while being safe\nCrop out unimportant parts\nMake sure things are in focus", comment: "take better photo tips")
            cell.actionButton?.setTitle(NSLocalizedString("Start Over", comment: "start species identification over button title"), for: .normal)
            cell.actionButton?.backgroundColor = UIColor.clear
            cell.actionButton?.tintColor = UIColor.white
            cell.actionButton?.layer.cornerRadius = 22
            cell.actionButton?.layer.borderColor = UIColor.INat.Green.cgColor
            cell.actionButton?.layer.borderWidth = 2.0
            cell.actionButton?.clipsToBounds = true
            cell.actionButton?.addTarget(self, action: #selector(ChallengeResultsViewController.startOverPressed), for: .touchUpInside)
        }
    }
    
    @objc
    func okPressed() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc
    func startOverPressed() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc
    func addToCollection() {
        // add to realm collection
        if let score = self.resultScore {
            
            let photo = PhotoRealm()
            photo.mediumUrl = score.taxon.default_photo?.medium_url
            photo.squareUrl = score.taxon.default_photo?.square_url
            
            let taxon = TaxonRealm()
            taxon.id = score.taxon.id
            taxon.name = score.taxon.name
            taxon.preferredCommonName = score.taxon.preferred_common_name
            taxon.defaultPhoto = photo
            taxon.iconicTaxonId = score.taxon.iconic_taxon_id

            let obs = ObservationRealm()
            obs.uuidString = UUID().uuidString
            obs.taxon = taxon
            
            // always use today's collection date, not photo taken date
            obs.date = Date()
            
            if let truncatedCoord = self.takenLocation?.coordinate.truncate(places: 2) {
                obs.latitude = Float(truncatedCoord.latitude)
                obs.longitude = Float(truncatedCoord.longitude)
            }
            
            let realm = try! Realm()
            try! realm.write {
                realm.add(obs, update: true)
            }
 
            // save photo to documents directory
            if let imageFromUser = self.imageFromUser, let data = UIImageJPEGRepresentation(imageFromUser, 0.9)  {
                if let photoPath = obs.pathForImage() {
                    try? data.write(to: photoPath)
                }
            }
            
            // notify challenges VC via delegate to dismiss & animate
            self.delegate?.addedToCollection(score.taxon)
        }

    }
}


// MARK: - UITableViewDataSource
extension ChallengeResultsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.resultsLoaded {
            return 4
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.item == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: titleCellId, for: indexPath) as! ResultsTitleCell
            self.configureTitleCell(cell)
            return cell
        } else if indexPath.item == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: dividerCellId, for: indexPath) as! ResultsDividerCell
            self.configureDividerCell(cell)
            return cell
        } else if indexPath.item == 2 {
            if self.resultScore != nil {
                // if a match, always show two photos (your photo and match or score)
                let cell = tableView.dequeueReusableCell(withIdentifier: dualImageCellId, for: indexPath) as! ResultsDualImageCell
                self.configureImageTaxonCell(cell)
                return cell
            } else if self.targetTaxon != nil {
                // if a target, always show to photos (your photo and target)
                let cell = tableView.dequeueReusableCell(withIdentifier: dualImageCellId, for: indexPath) as! ResultsDualImageCell
                self.configureImageTaxonCell(cell)
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: singleImageCellId, for: indexPath) as! ResultsSingleImageCell
                self.configureImageCell(cell)
                return cell
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: actionCellId, for: indexPath) as! ResultsActionCell
            self.configureActionCell(cell)
            return cell
        }
    }
}
