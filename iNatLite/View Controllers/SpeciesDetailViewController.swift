//
//  SpeciesDetailViewController.swift
//  iNatLite
//
//  Created by Alex Shepard on 2/14/18.
//  Copyright © 2018 iNaturalist. All rights reserved.
//

import UIKit
import Imaginary
import Auk
import MapKit
import CoreLocation
import Charts
import Gallery
import FontAwesomeKit

private let speciesImageCellId = "SpeciesImageCell"
private let speciesNameCellId = "SpeciesNameCell"
private let speciesCategoryCellId = "SpeciesCategoryCell"
private let speciesLocationCellId = "SpeciesLocationCell"
private let speciesPhenologyCellId = "SpeciesPhenologyCell"
private let speciesAboutCellId = "SpeciesAboutCell"
private let speciesSeenStatsCellId = "SpeciesSeenStatsCell"

private let observationMarkerId = "observationMaker"


class SpeciesDetailViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView?
    @IBOutlet var addView: UIView?
    @IBOutlet var addButton: UIButton?
    
    var species: Taxon?
    var userPlaceName: String?
    var contextCoordinate: CLLocationCoordinate2D?
    var obsCountInPlace: Int?
    var boundingBox: BoundingBox?
    var histogramData: [String: Int]?
    
    var activePhotoAttribution: String?
    
    var observation: ObservationRealm?
    
    var seen = false
    
    var speciesId: Int? {
        get {
            if let species = self.species {
                return species.id
            } else if let observation = self.observation, let species = observation.taxon {
                return species.id
            } else {
                return nil
            }
        }
    }
    
    var displayCoordinate: CLLocationCoordinate2D? {
        get {
            if let observation = self.observation,
                CLLocationCoordinate2DIsValid(observation.coordinate) {
                return observation.coordinate.truncate(places: 2)
            } else if let coordinate = self.contextCoordinate {
                return coordinate
            } else {
                return nil
            }
        }
    }
    
    var placeName: String? {
        get {
            if let observation = self.observation,
                let name = observation.placeName {
                return name
            } else if let name = self.userPlaceName {
                return name
            } else {
                return nil
            }
        }
    }

    @IBAction func licensePressed() {
        if let attr = self.activePhotoAttribution {
            let alert = UIAlertController(title: "License", message: attr, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func addPressed() {
        Gallery.Config.tabsToShow = [.cameraTab, .imageTab]
        Gallery.Config.Camera.imageLimit = 1
        Gallery.Config.Camera.recordLocation = true
        
        let gallery = GalleryController()
        if let nav = self.navigationController, let challenges = nav.viewControllers.first as? ChallengesViewController {
            gallery.delegate = challenges
            let nav = UINavigationController(rootViewController: gallery)
            nav.navigationBar.barStyle = .blackTranslucent
            nav.navigationBar.tintColor = .white
            nav.delegate = challenges
            present(nav, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        // hide the add button if they've already seen it
        if seen == true, let addView = self.addView {
            let filteredConstraints = addView.constraints.filter { $0.identifier == "addViewHeight" }
            if let addViewHeight = filteredConstraints.first {
                addViewHeight.constant = 0
                self.view.setNeedsLayout()
            }
        } else {
            addView?.backgroundColor = UIColor.INat.SpeciesAddButtonBackground
            addButton?.backgroundColor = UIColor.INat.CategoryForeground
            addButton?.tintColor = UIColor.INat.SpeciesChicletLabelBackground
            addButton?.layer.cornerRadius = 20
            addButton?.clipsToBounds = true
            if let plus = FAKIonIcons.androidAddCircleIcon(withSize: 20) {
                plus.addAttribute(NSAttributedStringKey.foregroundColor.rawValue, value: UIColor.INat.SpeciesChicletLabelBackground)
                let attrStr = NSMutableAttributedString(attributedString: plus.attributedString())
                attrStr.append(NSAttributedString(string: " Found It!"))
                addButton?.setAttributedTitle(attrStr, for: .normal)
            }
        }
        
        if self.observation == nil {
            self.title = "Collect This!"
        } else {
            self.title = "Collected"
        }
        
        self.tableView?.backgroundColor = UIColor.INat.DarkBlue
        self.view.backgroundColor = UIColor.INat.DarkBlue
        
        // avoid extra lines below content
        self.tableView?.tableFooterView = UIView()
        
        // load a bunch of data
        if let speciesId = speciesId {
            // full taxon for photos
            self.loadFullTaxonForSpeciesId(speciesId)
            // histogram for phenology chart
            self.loadHistogramForSpeciesId(speciesId, coordinate: self.displayCoordinate)
            
            if let coordinate = self.displayCoordinate {
                // bbox for map
                self.loadBBoxForSpeciesId(speciesId, coordinate: coordinate)
                // the count we use for the challenges screen is limited to only mobile, and only
                // a few months around the current month. we want the full count on iNat for the stats
                // on this screen.
                self.loadSpeciesCountsForSpeciesId(speciesId, coordinate: coordinate)
            }
        }
    }
    
    func loadFullTaxonForSpeciesId(_ speciesId: Int) {
        INatApi().fullTaxonForSpeciesId(speciesId) { (response, error) in
            if let response = response, let results = response.results, let first = results.first {
                self.species = first
                self.tableView?.reloadData()
            } else if let error = error {
                // display error
            } else {
                // display no data
            }
        }
    }
    
    func loadBBoxForSpeciesId(_ speciesId: Int, coordinate: CLLocationCoordinate2D) {
        INatApi().bboxForSpeciesId(speciesId, coordinate: coordinate) { (response, error) in
            if let response = response, let bounds = response.total_bounds {
                self.boundingBox = bounds
                let mapIndexPath = IndexPath(item: 3, section: 0)
                self.tableView?.reloadRows(at: [mapIndexPath], with: .none)
            } else if let error = error {
                // display error
            } else {
                // display no data
            }
        }
    }

    func loadHistogramForSpeciesId(_ speciesId: Int, coordinate: CLLocationCoordinate2D?) {
        INatApi().histogramForSpeciesId(speciesId, coordinate: coordinate) { (response, error) in
            if let response = response, let month_of_year = response.results?.month_of_year {
                self.histogramData = month_of_year
                let chartIndexPath = IndexPath(item: 4, section: 0)
                self.tableView?.reloadRows(at: [chartIndexPath], with: .none)
            } else if let error = error {
                // display error
            } else {
                // display no data
            }
        }
    }
    
    func loadSpeciesCountsForSpeciesId(_ speciesId: Int, coordinate: CLLocationCoordinate2D) {
        INatApi().countsForSpeciesId(speciesId, coordinate: coordinate) { (response, error) in
            if let response = response, let results = response.results, results.count > 0 {
                for result in results {
                    if result.taxon == self.species {
                        self.obsCountInPlace = result.count
                        let obsCountIndexPath = IndexPath(item: 5, section: 0)
                        self.tableView?.reloadRows(at: [obsCountIndexPath], with: .none)
                    }
                }
            } else if let error = error {
                // display error
            } else {
                // display no data
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? SpeciesMapViewController,
            let species = self.species,
            let boundingBox = self.boundingBox
        {
            dest.species = species
            dest.boundingBox = boundingBox
        }
    }
    
    // MARK: - tableview helpers
    
    func configurePhotoCell(_ cell: SpeciesImageCell) {
        
        cell.selectionStyle = .none

        if cell.scrollView?.delegate == nil {
            cell.scrollView?.delegate = self
        }
        cell.scrollView?.auk.removeAll()
        
        
        // show the user photo first
        if let observation = self.observation {
            cell.showCollectedUI()
            
            // show collection data
            var baseStr = "Collected"
            if let dateStr = observation.relativeDateString {
                baseStr.append(" \(dateStr)")
            }
            baseStr.append("!")
            cell.collectedLabel?.text = baseStr
            
            // show collection photo
            if let photoUrl = observation.pathForImage(),
                let photoData = NSData(contentsOf: photoUrl) as Data?,
                let photo = UIImage(data: photoData)
            {
                cell.scrollView?.auk.show(image: photo)
            }
            
        } else {
            cell.hideCollectedUI()
        }
        
        // show taxon photos after
        if let species = self.species {
            if let taxon_photos = species.taxon_photos {
                // show at most 10 taxon photos to avoid the
                // giant hundred item indicator
                for i in 0...min(taxon_photos.count, 10)-1 {
                    let tp = taxon_photos[i]
                    if let urlString = tp.photo.medium_url {
                        cell.scrollView?.auk.show(url: urlString)
                    }
                }
                if let first = taxon_photos.first,
                    let attr = first.photo.attribution
                {
                    cell.photoLicenseButton?.setTitle("CC", for: .normal)
                    self.activePhotoAttribution = attr
                }
            } else if let photo = species.default_photo, let urlString = photo.medium_url {
                cell.scrollView?.auk.show(url: urlString)
                cell.photoLicenseButton?.setTitle("CC", for: .normal)
            }
        }
    }

}

// MARK: - UITableViewDataSource

extension SpeciesDetailViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.item == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: speciesImageCellId, for: indexPath) as! SpeciesImageCell
            
            self.configurePhotoCell(cell)
            
            return cell
        } else if indexPath.item == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: speciesNameCellId, for: indexPath) as! SpeciesNameCell
            cell.selectionStyle = .none
            
            if let species = self.species {
                cell.commonName?.text = species.anyNameCapitalized
                cell.scientificNameLabel?.text = "Scientific Name:"
                cell.scientificName?.text = species.name
            } else if let observation = self.observation, let taxon = observation.taxon {
                cell.commonName?.text = taxon.anyNameCapitalized
                cell.scientificNameLabel?.text = "Scientific Name:"
                cell.scientificName?.text = taxon.name
            }
            
            return cell
        } else if indexPath.item == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: speciesCategoryCellId, for: indexPath) as! SpeciesCategoryCell
            cell.selectionStyle = .none
            
            if let species = self.species {
                if let iconic = species.iconicTaxon() {
                    cell.categoryLabel?.text = "Category: \(iconic.anyNameCapitalized)"
                } else {
                    cell.categoryLabel?.text = "Category: Other"
                }
                
                if let iconicImage = species.iconicImageName() {
                    cell.categoryImageView?.image = UIImage(named: iconicImage)?.withRenderingMode(.alwaysTemplate)
                }
            }
            
            return cell
        } else if indexPath.item == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: speciesLocationCellId, for: indexPath) as! SpeciesLocationCell
            cell.selectionStyle = .none
            
            cell.mapView?.delegate = self
            cell.mapView?.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: observationMarkerId)
            
            if let species = self.species {
                if self.observation == nil {
                    cell.locationLabel?.text = "Where are people seeing it nearby?"
                } else {
                    cell.locationLabel?.text = "Location"
                }
                
                let template = "https://api.inaturalist.org/v1/colored_heatmap/{z}/{x}/{y}.png?taxon_id=\(species.id)"
                let overlay = MKTileOverlay(urlTemplate: template)
                overlay.tileSize = CGSize(width: 512, height: 512)
                overlay.canReplaceMapContent = false
                cell.mapView?.addOverlays([overlay], level: .aboveRoads)

                if let boundingBox = self.boundingBox {
                    let bboxRect = boundingBox.mapRect()
                    let inset = -bboxRect.size.width * 0.10;
                    let zoomRect = MKMapRectInset(bboxRect, inset, inset)
                    cell.mapView?.setVisibleMapRect(zoomRect, animated: false)
                }
                
                if let observation = self.observation {
                    if CLLocationCoordinate2DIsValid(observation.coordinate) {
                        // add a map pin at the area they found it
                        cell.mapView?.addAnnotation(observation)
                    } else  {
                        // hide the map and say no information is visible
                        cell.mapView?.isHidden = true
                        cell.mapProblemLabel?.isHidden = false
                        cell.mapProblemLabel?.text = "Location Unknown"
                    }
                }
                
            }
            
            return cell
        } else if indexPath.item == 4 {
            let cell = tableView.dequeueReusableCell(withIdentifier: speciesPhenologyCellId, for: indexPath) as! SpeciesPhenologyCell
            cell.selectionStyle = .none
            
            cell.phenologyLabel?.text = "When is the best time to find it?"
            
            if let histogramData = self.histogramData {
                
                let sortedKeys = histogramData.keys.sorted { Int($0)! < Int($1)! }
                
                var dataEntry = [ChartDataEntry]()
                for key in sortedKeys {
                    let point = ChartDataEntry(x: Double(sortedKeys.index(of: key)!), y: Double(histogramData[key]!))
                    dataEntry.append(point)
                }
                
                let chartDataSet = LineChartDataSet(values: dataEntry, label: "Observations")
                cell.displayChartDataSet(chartDataSet, max: histogramData.values.max()!)
                
            }
            
            return cell
        } else if indexPath.item == 5 {
            let cell = tableView.dequeueReusableCell(withIdentifier: speciesAboutCellId, for: indexPath) as! SpeciesAboutCell
            cell.selectionStyle = .none
            
            cell.aboutLabel?.text = "About"
            if let species = self.species, let text = species.wikipediaText {
                cell.wikipediaTextLabel?.text = text
            }
            
            return cell
        } else if indexPath.item == 6 {
            let cell = tableView.dequeueReusableCell(withIdentifier: speciesSeenStatsCellId, for: indexPath) as! SpeciesSeenStatsCell
            cell.selectionStyle = .none
            
            cell.seenLabel?.text = "Seen Using iNaturalist"
            
            if let species = self.species, let count = species.observations_count {
                cell.worldwideStatsLabel?.text = "\(count) times worldwide"
            }
            if let count = obsCountInPlace, let placeName = placeName {
                cell.localStatsLabel?.text = "\(count) times near \(placeName)"
            } else {
                cell.localStatsLabel?.text = nil
            }
            
            return cell
        } else {
            return  tableView.dequeueReusableCell(withIdentifier: "fail", for: indexPath)
        }
        
    }
}


// MARK: - UITableViewDelegate
extension SpeciesDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.item == 3 {
            self.performSegue(withIdentifier: "segueToSpeciesMap", sender: self.species)
        }
    }
}

// MARK: - MKMapViewDelegate
extension SpeciesDetailViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        return MKTileOverlayRenderer(tileOverlay: overlay as! MKTileOverlay)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let obsAnnotation = annotation as? ObservationRealm else {
            return nil
        }
        
        if let view = mapView.dequeueReusableAnnotationView(withIdentifier: observationMarkerId, for: obsAnnotation) as? MKMarkerAnnotationView {
            view.annotation = obsAnnotation
            return view
        } else {
            return nil
        }
    }
}

extension SpeciesDetailViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        struct Animating {
            static var isAnimating = false
        }
        
        let photoIp = IndexPath(item: 0, section: 0)
        if let cell = self.tableView?.cellForRow(at: photoIp) as? SpeciesImageCell {
            if self.observation != nil, let index = scrollView.auk.currentPageIndex, index == 0 {
                if !Animating.isAnimating {
                    Animating.isAnimating = true
                    UIView.animate(withDuration: 0.3, animations: {
                        cell.showCollectedUI()
                    }, completion: { (finished) in
                        Animating.isAnimating = false
                    })
                }
            } else {
                if !Animating.isAnimating {
                    Animating.isAnimating = true
                    UIView.animate(withDuration: 0.3, animations: {
                        cell.hideCollectedUI()
                    }, completion: { (finished) in
                        Animating.isAnimating = false
                    })
                }
            }
        }
        
        
        var taxonPhotoIndex = scrollView.auk.currentPageIndex
        if self.observation != nil, let index = taxonPhotoIndex {
            taxonPhotoIndex = index - 1
        }
        
        if let pageIndex = taxonPhotoIndex, pageIndex > 0, let species = self.species {
            if let taxonPhotos = species.taxon_photos {
                let taxonPhoto = taxonPhotos[pageIndex]
                if let attr = taxonPhoto.photo.attribution {
                    self.activePhotoAttribution = attr
                }
            } else if let defaultPhoto = species.default_photo {
                if let attr = defaultPhoto.attribution {
                    self.activePhotoAttribution = attr
                }
            }
        }
    }
}

