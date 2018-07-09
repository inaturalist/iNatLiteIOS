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
            let licenseText = NSLocalizedString("License", comment: "The creative commons license for a photograph")
            let alert = UIAlertController(title: licenseText, message: attr, preferredStyle: .alert)
            let okButtonTitle = NSLocalizedString("OK", comment: "OK button title")
            alert.addAction(UIAlertAction(title: okButtonTitle, style: .default, handler: nil))
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
            addView?.backgroundColor = UIColor(named: .SpeciesAddButtonBackground)
            addButton?.backgroundColor = UIColor(named: .CategoryForeground)
            addButton?.tintColor = UIColor(named: .SpeciesChicletLabelBackground)
            addButton?.layer.cornerRadius = 20
            addButton?.clipsToBounds = true
            if let plus = FAKIonIcons.androidAddCircleIcon(withSize: 20) {
                plus.addAttribute(NSAttributedStringKey.foregroundColor.rawValue, value: UIColor(named: .SpeciesChicletLabelBackground))
                let attrStr = NSMutableAttributedString(attributedString: plus.attributedString())
                attrStr.append(NSAttributedString(string: " Found It!"))
                addButton?.setAttributedTitle(attrStr, for: .normal)
            }
        }
        
        if self.observation == nil {
            self.title = NSLocalizedString("Collect This!", comment: "Title for species details screen if the user hasn't collected this species")
        } else {
            self.title = NSLocalizedString("Collected", comment: "Title for species details screen if the user has collected this species")
        }
        
        self.tableView?.backgroundColor = UIColor(named: .DarkBlue)
        self.view.backgroundColor = UIColor(named: .DarkBlue)
        
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
            if let dateStr = observation.relativeDateString {
                cell.collectedLabel?.text = String(format: NSLocalizedString("Collected %@!", comment: "Date the user collected a species"), dateStr)
            } else {
                cell.collectedLabel?.text = NSLocalizedString("Collected!", comment: "The user collected a species, no date specified")
            }
            
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
                    self.activePhotoAttribution = attr
                }
            } else if let photo = species.default_photo, let urlString = photo.medium_url {
                cell.scrollView?.auk.show(url: urlString)
            }
            
            let ccText = NSLocalizedString("CC", comment: "CC is short for Creative Commons, which is how our photos are licensed. Tapping this button shows license details. This text should be very short.")
            cell.photoLicenseButton?.setTitle(ccText, for: .normal)

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
            
            cell.scientificNameLabel?.text = NSLocalizedString("Scientific Name:", comment: "Below this label is the scientific name of this species.")

            if let species = self.species {
                cell.commonName?.text = species.displayName
                cell.scientificName?.text = species.name
            } else if let observation = self.observation, let taxon = observation.taxon {
                cell.commonName?.text = taxon.displayName
                cell.scientificName?.text = taxon.name
            }
            
            return cell
        } else if indexPath.item == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: speciesCategoryCellId, for: indexPath) as! SpeciesCategoryCell
            cell.selectionStyle = .none
            
            if let species = self.species {
                if let iconic = species.iconicTaxon() {
                    cell.categoryLabel?.text = String(format: NSLocalizedString("Category: %@", comment: "Category of this species. Examples are Bird, Insect, Plant, etc"), iconic.displayName)
                } else {
                    cell.categoryLabel?.text = NSLocalizedString("Category: Other", comment: "If this species doesn't fit into our standard categories, then we just say other category.")
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
                    cell.locationLabel?.text = NSLocalizedString("Where are peope seeing it nearby?", comment: "Title for map section of species details")
                } else {
                    cell.locationLabel?.text = NSLocalizedString("Location", comment: "Title for map section of collected species, showing where you collected it")
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
                        cell.mapProblemLabel?.text = NSLocalizedString("Location Unknown", comment: "When we are unable to find location information during species details")
                    }
                }
                
            }
            
            return cell
        } else if indexPath.item == 4 {
            let cell = tableView.dequeueReusableCell(withIdentifier: speciesPhenologyCellId, for: indexPath) as! SpeciesPhenologyCell
            cell.selectionStyle = .none
            
            cell.phenologyLabel?.text = NSLocalizedString("When is the best time to find it?", comment: "Title for chart showing when this species occurs over time")
            
            if let histogramData = self.histogramData {
                
                let sortedKeys = histogramData.keys.sorted { Int($0)! < Int($1)! }
                
                var dataEntry = [ChartDataEntry]()
                for key in sortedKeys {
                    let point = ChartDataEntry(x: Double(sortedKeys.index(of: key)!), y: Double(histogramData[key]!))
                    dataEntry.append(point)
                }
                
                let chartDataSet = LineChartDataSet(values: dataEntry, label: nil)
                cell.displayChartDataSet(chartDataSet, max: histogramData.values.max()!)
                
            }
            
            return cell
        } else if indexPath.item == 5 {
            let cell = tableView.dequeueReusableCell(withIdentifier: speciesAboutCellId, for: indexPath) as! SpeciesAboutCell
            cell.selectionStyle = .none
            
            cell.aboutLabel?.text = NSLocalizedString("About", comment: "Title for About section")
            if let species = self.species, let text = species.wikipediaText {
                cell.wikipediaTextLabel?.text = text
            }
            
            return cell
        } else if indexPath.item == 6 {
            let cell = tableView.dequeueReusableCell(withIdentifier: speciesSeenStatsCellId, for: indexPath) as! SpeciesSeenStatsCell
            cell.selectionStyle = .none
            
            cell.seenLabel?.text = NSLocalizedString("Seen Using iNaturalist", comment: "Title for table showing stats on how often this species has been seen on inaturalist.org")
            
            if let species = self.species, let count = species.observations_count {
                cell.worldwideStatsLabel?.text = String(format: NSLocalizedString("%d times worldwide", comment: "number of times this species was seen on iNaturalist.org worldwide"), count)
            }
            if let count = obsCountInPlace, let placeName = placeName {
                cell.localStatsLabel?.text = String(format: NSLocalizedString("%d times near %@", comment: "number of times this species was seen on iNaturalist.org near the named place"), count, placeName)
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

