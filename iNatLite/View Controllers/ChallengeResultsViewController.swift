//
//  ChallengeResultsViewController.swift
//  iNatLite
//
//  Created by Alex Shepard on 2/16/18.
//  Copyright © 2018 iNaturalist. All rights reserved.
//

import UIKit
import JWT
import Alamofire
import FontAwesomeKit
import RealmSwift
import CoreLocation

private let titleCellId = "ResultsTitleCell"
private let dividerCellId = "ResultsDividerCell"
private let imageCellId = "ResultsImageCell"
private let imageTaxonCellId = "ResultsImageTaxonCell"
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
    var seenTaxaIds = [Int]()
    
    weak var delegate: ChallengeResultsDelegate?
    
    func loadResults() {
        if let imageFromUser = self.imageFromUser {
            let jwtStr = JWT.encode(claims: ["application": "ios"], algorithm: .hs512(AppConfig.visionSekret.data(using: .utf8)!))
            // resize the image to 299x299
            let rect = CGRect(x: 0, y: 0, width: 299, height: 299)
            let newSize = CGSize(width: 299, height: 299)
            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            imageFromUser.draw(in: rect)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            let data = UIImageJPEGRepresentation(newImage!, 1)
            
            var params = [String: String]()
            
            if let loc = self.takenLocation {
                let fuzzedCoordinate = loc.coordinate.truncate(places: 2)
                params["lat"] = "\(fuzzedCoordinate.latitude)"
                params["lng"] = "\(fuzzedCoordinate.longitude)"
            }
            if let date = self.takenDate {
                params["observed_on"] = "\(date.timeIntervalSince1970)"
            }
            
            self.activitySpinner?.isHidden = false
            self.activitySpinner?.startAnimating()
            
            
            
            Alamofire.upload(multipartFormData:{ multipartFormData in
                multipartFormData.append(data!, withName: "image", fileName: "file.jpg", mimeType: "image/jpeg")
                for (key, value) in params {
                    multipartFormData.append(value.data(using: .utf8)!, withName: key)
                }
            },
                             usingThreshold:UInt64.init(),
                             to:"https://api.inaturalist.org/v1/computervision/score_image",
                             method:.post,
                             headers:["Authorization": jwtStr],
                             encodingCompletion: { encodingResult in
                                switch encodingResult {
                                case .success(let upload, _, _):
                                    upload.responseData { responseData in
                                        do {
                                            // TODO: check for responseData.data
                                            let serverResponse = try JSONDecoder().decode(ScoreResponse.self, from: responseData.data!)
                                            for result in serverResponse.results {
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
                                            self.commonAncestor = serverResponse.common_ancestor
                                            self.resultsLoaded = true
                                            self.activitySpinner?.isHidden = true
                                            self.activitySpinner?.stopAnimating()
                                            self.tableView?.reloadData()
                                        } catch {
                                            self.noticeLabel?.text = "Can't load computer vision suggestions. Try again later."
                                            self.noticeLabel?.isHidden = false
                                            self.activitySpinner?.isHidden = true
                                            self.activitySpinner?.stopAnimating()
                                        }
                                    }
                                case .failure(let encodingError):
                                    self.noticeLabel?.text = encodingError.localizedDescription
                                    self.noticeLabel?.isHidden = false
                                    self.activitySpinner?.isHidden = true
                                    self.activitySpinner?.stopAnimating()
                                }
            })
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
        if let observations = self.observations {
            for observation in observations {
                if let obsTaxon = observation.taxon {
                    self.seenTaxaIds.append(obsTaxon.id)
                }
            }
        }
        
        self.loadResults()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            cell.dividerImageView?.image = UIImage(named: "icn-results-unknown")
        }
    }

    func configureTitleCell(_ cell: ResultsTitleCell) {
        cell.backgroundColor = UIColor.clear

        if let score = self.resultScore {
            if let target = self.targetTaxon {
                if target == score.taxon {
                    // you found your target
                    cell.title?.text = "It's a Match!"
                    cell.subtitle?.text = "You saw a \(score.taxon.anyNameCapitalized)."
                } else {
                    // you found something else
                    cell.title?.text = "Good Try!"
                    cell.subtitle?.text = "However, this isn't a \(target.anyNameCapitalized), it's a \(score.taxon.anyNameCapitalized)."
                }
            } else {
                if self.seenTaxaIds.contains(score.taxon.id) {
                    cell.title?.text = "Deja Vu!"
                    cell.subtitle?.text = "Looks like you already collected a \(score.taxon.anyNameCapitalized)."
                } else {
                    cell.title?.text = "Sweet!"
                    cell.subtitle?.text = "You saw a \(score.taxon.anyNameCapitalized)."
                }
            }
        } else {
            cell.title?.text = "Hrmmmmmm"
            if let ancestor = self.commonAncestor {
                cell.subtitle?.text = "We think this is a photo of \(ancestor.taxon.anyNameCapitalized), but we can't say for sure what species it is."
            } else {
                cell.subtitle?.text = "We can't figure this one out. Please try some adjustments."
            }
        }
    }
    
    func configureImageCell(_ cell: ResultsImageCell) {
        cell.backgroundColor = UIColor.white.withAlphaComponent(0.07)
        
        cell.userImageView?.image = self.imageFromUser
        cell.userLabel?.text = nil
    }
    
    func configureImageTaxonCell(_ cell: ResultsImageTaxonCell) {
        cell.backgroundColor = UIColor.white.withAlphaComponent(0.07)

        // left label
        if let score = self.resultScore {
            cell.userLabel?.text = "Your Photo:\n\(score.taxon.anyNameCapitalized)"
        } else {
            cell.userLabel?.text = "Your Photo"
        }

        // left photo is always user photo
        cell.userImageView?.image = self.imageFromUser
        
        // right label
        if let target = self.targetTaxon {
            cell.taxonLabel?.text = "Target Species:\n\(target.anyNameCapitalized)"
        } else if let score = self.resultScore {
            // identified name
            cell.taxonLabel?.text = "Identified Species:\n\(score.taxon.anyNameCapitalized)"
        }
        
        // right photo
        if let target = self.targetTaxon {
            // show the target taxon photo
            if let photo = target.default_photo,
                let urlString = photo.medium_url,
                let url = URL(string: urlString)
            {
                cell.taxonImageView?.setImage(url: url)
            }
        } else if let score = self.resultScore {
            // show the identified taxon photo
            if let photo = score.taxon.default_photo,
                let urlString = photo.medium_url,
                let url = URL(string: urlString)
            {
                cell.taxonImageView?.setImage(url: url)
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
                                cell.infoLabel?.text = "You collected a photo of a \(obsTaxon.anyNameCapitalized) on \(obsDate)."
                                cell.infoLabel?.textColor = UIColor.INat.SpeciesAddButton
                                
                                cell.actionButton?.setTitle("OK", for: .normal)
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
                        cell.actionButton?.setTitle("Add to Collection", for: .normal)
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
                        cell.infoLabel?.text = "You still need to collect a \(result.taxon.anyNameCapitalized). Would you like to collect it now?"
                        cell.actionButton?.setTitle("Add to Collection", for: .normal)
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
                    cell.actionButton?.setTitle("Add to Collection", for: .normal)
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
            cell.infoLabel?.text = "Here are some photo tips:\nGet as close as possible while being safe\nCrop out unimportant parts\nMake sure things are in focus"

            cell.actionButton?.setTitle("Start Over", for: .normal)
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
                let cell = tableView.dequeueReusableCell(withIdentifier: imageTaxonCellId, for: indexPath) as! ResultsImageTaxonCell
                self.configureImageTaxonCell(cell)
                return cell
            } else if self.targetTaxon != nil {
                // if a target, always show to photos (your photo and target)
                let cell = tableView.dequeueReusableCell(withIdentifier: imageTaxonCellId, for: indexPath) as! ResultsImageTaxonCell
                self.configureImageTaxonCell(cell)
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: imageCellId, for: indexPath) as! ResultsImageCell
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
