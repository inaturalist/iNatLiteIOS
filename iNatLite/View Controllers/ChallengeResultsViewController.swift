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
    
    var challengeResults = ChallengeResults()

    var seenTaxaIds: [Int] {
        get {
            do {
                let realm = try Realm()
                let observations = realm.objects(ObservationRealm.self)
                return observations.filter { return $0.taxon != nil }.map { return $0.taxon!.id }
            } catch {
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
                    let challengeResults = ChallengeResults()
                    challengeResults.resultsLoaded = true
                    challengeResults.targetTaxon = self.targetTaxon
                    
                    for result in response.results {
                        if let target = self.targetTaxon,
                            target.id == result.taxon.id,
                            let score = result.combined_score,
                            score > 85
                        {
                            challengeResults.resultScore = result
                            break
                        } else if let score = result.combined_score,
                            score > 97
                        {
                            challengeResults.resultScore = result
                            break
                        }
                    }
                    challengeResults.commonAncestor = response.common_ancestor
                    self.challengeResults = challengeResults
                    
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
        
        
        self.loadResults()
    }

    
    // MARK: - UITableViewCell helpers
    
    func configureDividerCell(_ cell: ResultsDividerCell) {
        cell.backgroundColor = UIColor.clear
        cell.scrim?.backgroundColor = UIColor.white.withAlphaComponent(0.07)
        cell.setDividerStyle(challengeResults.dividerStyle())
    }

    func configureTitleCell(_ cell: ResultsTitleCell) {
        cell.backgroundColor = UIColor.clear
        
        cell.title?.text = challengeResults.title()
        cell.subtitle?.text = challengeResults.subtitle()
    }
    
    func configureSingleImageCell(_ cell: ResultsSingleImageCell) {
        cell.backgroundColor = UIColor.white.withAlphaComponent(0.07)
        
        cell.userImageView?.image = self.imageFromUser
        cell.userLabel?.text = nil
    }
    
    func configureDualImageCell(_ cell: ResultsDualImageCell) {
        cell.backgroundColor = UIColor.white.withAlphaComponent(0.07)
        
        // left photo is always user photo
        cell.leadingImageView?.image = self.imageFromUser
        cell.leadingImageLabel?.text = challengeResults.dualImageLeadingLabelText()
        
        
        cell.trailingImageLabel?.text = challengeResults.dualImageTrailingLabelText()
        if let url = challengeResults.urlForTrailingImageView() {
            cell.trailingImageView?.setImage(url: url)
        }
    }
    
    func configureActionCell(_ cell: ResultsActionCell) {
        cell.backgroundColor = UIColor.clear
        
        cell.infoLabel?.text = challengeResults.infoLabelText()
        cell.setActionButtonStyle(challengeResults.actionButtonStyle())
        cell.actionButton?.setTitle(challengeResults.actionButtonTitle(), for: .normal)
        cell.actionButton?.addTarget(self, action: challengeResults.actionButtonSelector(), for: .touchUpInside)
        
        if let result = challengeResults.resultScore, self.seenTaxaIds.contains(result.taxon.id) {
            cell.infoLabel?.textColor = UIColor.INat.SpeciesAddButton
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
        if let score = challengeResults.resultScore {
            
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
        if challengeResults.resultsLoaded {
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
            if challengeResults.resultScore != nil {
                // if a match, always show two photos (your photo and match or score)
                let cell = tableView.dequeueReusableCell(withIdentifier: dualImageCellId, for: indexPath) as! ResultsDualImageCell
                self.configureDualImageCell(cell)
                return cell
            } else if challengeResults.targetTaxon != nil {
                // if a target, always show to photos (your photo and target)
                let cell = tableView.dequeueReusableCell(withIdentifier: dualImageCellId, for: indexPath) as! ResultsDualImageCell
                self.configureDualImageCell(cell)
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: singleImageCellId, for: indexPath) as! ResultsSingleImageCell
                self.configureSingleImageCell(cell)
                return cell
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: actionCellId, for: indexPath) as! ResultsActionCell
            self.configureActionCell(cell)
            return cell
        }
    }
}
