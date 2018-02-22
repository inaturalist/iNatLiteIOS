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

private let titleCellId = "ResultsTitleCell"
private let dividerCellId = "ResultsDividerCell"
private let imageCellId = "ResultsImageCell"
private let imageTaxonCellId = "ResultsImageTaxonCell"
private let actionCellId = "ResultsActionCell"

class ChallengeResultsViewController: UITableViewController {
    
    var image: UIImage?
    var targetTaxon: Taxon?
    var resultScore: TaxonScore?
    var resultsLoaded = false

    func loadResults() {
        if let image = self.image {
            let jwtStr = JWT.encode(claims: ["application": "ios"], algorithm: .hs512(AppConfig.visionSekret.data(using: .utf8)!))
            // resize the image to 299x299
            let rect = CGRect(x: 0, y: 0, width: 299, height: 299)
            let newSize = CGSize(width: 299, height: 299)
            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            image.draw(in: rect)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            let data = UIImageJPEGRepresentation(newImage!, 1)
            
            var params = [String: String]()
            
            /*
            if let loc = self.locationTaken {
                params["lat"] = "\(loc.coordinate.latitude)"
                params["lng"] = "\(loc.coordinate.longitude)"
            }
            if let date = self.dateTaken {
                params["observed_on"] = "\(date.timeIntervalSince1970)"
            }
            */
            
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
                                        let serverResponse = try! JSONDecoder().decode(ScoreResponse.self, from: responseData.data!)
                                        print(serverResponse)
                                        var goodResults = [TaxonScore]()
                                        for result in serverResponse.results {
                                            if result.combined_score > 1 {
                                                goodResults.append(result)
                                            }
                                        }
                                        print(goodResults)
                                        if goodResults.count == 1 {
                                            self.resultScore = goodResults.first
                                        }
                                        self.resultsLoaded = true
                                        self.tableView.reloadData()
                                    }
                                case .failure(let encodingError):
                                    print(encodingError)
                                }
            })
        }
    }

    
    // MARK: - UIViewController lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // trick to hide extra lines after the tableview cells run out
        self.tableView.tableFooterView = UIView()
        
        view.backgroundColor = UIColor.INat.LighterDarkBlue
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.loadResults()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.resultsLoaded {
            return 4
        } else {
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.item == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: titleCellId, for: indexPath) as! ResultsTitleCell
            self.configureTitleCell(cell)
            return cell
        } else if indexPath.item == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: dividerCellId, for: indexPath) as! ResultsDividerCell
            self.configureDividerCell(cell)
            return cell
        } else if indexPath.item == 2 {
            if let score = self.resultScore {
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
    
    // MARK: - UITableViewCell helpers
    
    func configureDividerCell(_ cell: ResultsDividerCell) {
        cell.backgroundColor = UIColor.clear
        cell.scrim?.backgroundColor = UIColor.INat.DarkBlue
        
        if let score = self.resultScore {
            cell.dividerImageView?.image = UIImage(named: "icn-results-match")
        } else {
            cell.dividerImageView?.image = UIImage(named: "icn-results-unknown")
        }
    }

    func configureTitleCell(_ cell: ResultsTitleCell) {
        cell.backgroundColor = UIColor.INat.DarkBlue

        if let score = self.resultScore {
            cell.title?.text = "Sweet!"
            cell.subtitle?.text = "You saw a \(score.taxon.anyName)."
        } else {
            cell.title?.text = "Hrmmmmmm"
            cell.subtitle?.text = "We can't figure this one out. Please try some adjustments."
        }
    }
    
    func configureImageCell(_ cell: ResultsImageCell) {
        cell.backgroundColor = UIColor.clear

        if self.resultScore == nil {
            cell.userImageView?.image = self.image
            cell.userLabel?.text = nil
        }
    }
    
    func configureImageTaxonCell(_ cell: ResultsImageTaxonCell) {
        cell.backgroundColor = UIColor.clear
        
        if let score = self.resultScore {
            cell.userImageView?.image = self.image
            cell.userLabel?.text = "Your Photo"
            if let photo = score.taxon.default_photo,
                let urlString = photo.medium_url,
                let url = URL(string: urlString)
            {
                cell.taxonImageView?.setImage(url: url)
            }
            cell.taxonLabel?.text = score.taxon.anyName
        }
    }
    
    func configureActionCell(_ cell: ResultsActionCell) {
        cell.backgroundColor = UIColor.clear
        
        if self.resultScore == nil {
            // show tips
            cell.infoLabel?.text = "Here are some photo tips:\nGet as close as possible while being safe\nCrop out unimportant parts\nMake sure things are in focus"
            cell.actionButton?.setTitle("Adjust Photo", for: .normal)
            cell.actionButton?.backgroundColor = UIColor.clear
            cell.actionButton?.tintColor = UIColor.white
            cell.actionButton?.layer.borderWidth = 1.0
            cell.actionButton?.layer.borderColor = UIColor.white.cgColor
            cell.actionButton?.layer.cornerRadius = 22
            cell.actionButton?.clipsToBounds = true

        } else {
            // show ok button
            cell.infoLabel?.text = nil
            cell.actionButton?.setTitle("Add to Collection", for: .normal)
            cell.actionButton?.backgroundColor = UIColor.INat.Green
            cell.actionButton?.tintColor = UIColor.white
            cell.actionButton?.layer.cornerRadius = 22
            cell.actionButton?.clipsToBounds = true
            cell.actionButton?.addTarget(self, action: #selector(ChallengeResultsViewController.addToCollection), for: .touchUpInside)
        }
    }
    
    @objc
    func addToCollection() {
        // add to realm collection
        if let score = self.resultScore {
            let obs = ObservationRealm()
            obs.uuidString = UUID().uuidString
            obs.taxonId = score.taxon.id
            // TODO: should we try to use photo creation date?
            obs.date = Date()
            
            let realm = try! Realm()
            try! realm.write {
                realm.add(obs, update: true)
            }
 
            // save photo to documents directory
            if let image = self.image, let data = UIImageJPEGRepresentation(image, 0.9)  {
                if let photoPath = obs.pathForImage() {
                    try? data.write(to: photoPath)
                }
            }
        }

        // notify challenges VC via delegate to dismiss & animate
        print("addToCollection")
        dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
