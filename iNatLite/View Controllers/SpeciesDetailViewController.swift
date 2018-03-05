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
import Alamofire
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

class SpeciesDetailViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView?
    @IBOutlet var addView: UIView?
    @IBOutlet var addButton: UIButton?
    
    var species: Taxon?
    var userPlaceName: String?
    var userCoordinate: CLLocationCoordinate2D?
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
    
    var coordinate: CLLocationCoordinate2D? {
        get {
            if let coord = self.userCoordinate {
                return coord
            } else if let observation = self.observation, let coord = observation.coordinate {
                return coord
            } else {
                return nil
            }
        }
    }
    
    var placeName: String? {
        get {
            if let name = self.userPlaceName {
                return name
            } else if let observation = self.observation, let  name = observation.placeName {
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
        Gallery.Config.tabsToShow = [.imageTab, .cameraTab]
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
                attrStr.append(NSAttributedString(string: " Make an Observation"))
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
        
        // reload the taxon from the server
        if let speciesId = speciesId, let url = URL(string: "https://api.inaturalist.org/v1/taxa/\(speciesId)") {
            Alamofire.request(url).responseData { response in
                if let data = response.result.value {
                    let response = try! JSONDecoder().decode(TaxaResponse.self, from: data)
                    print(response)
                    if let results = response.results, let first = results.first {
                        self.species = first
                        self.tableView?.reloadData()
                    }
                }
            }
        }
        
        // load the bounding box for this taxon/place
        if let coordinate = self.coordinate, let speciesId = speciesId {
            let url = "https://api.inaturalist.org/v1/observations?lat=\(coordinate.latitude)&lng=\(coordinate.longitude)&radius=50&taxon_id=\(speciesId)&per_page=1&return_bounds=true"
            Alamofire.request(url).responseData { response in
                if let data = response.result.value {
                    let response = try! JSONDecoder().decode(BoundingBoxResponse.self, from: data)
                    if let bounds = response.total_bounds {
                        self.boundingBox = bounds
                        let mapIndexPath = IndexPath(item: 3, section: 0)
                        self.tableView?.reloadRows(at: [mapIndexPath], with: .none)
                    }
                }
            }
        }
        
        // load the data for the histogram
        if let speciesId = self.speciesId {
            var histogramUrl = "https://api.inaturalist.org/v1/observations/histogram?taxon_id=\(speciesId)&date_field=observed&interval=month_of_year"
            
            if let coordinate = self.coordinate {
                histogramUrl.append("&lat=\(coordinate.latitude)&lng=\(coordinate.longitude)&radius=50")
            }
            Alamofire.request(histogramUrl).responseData { response in
                if let data = response.result.value {
                    let response = try! JSONDecoder().decode(HistogramResponse.self, from: data)
                    if let month_of_year = response.results?.month_of_year {
                        self.histogramData = month_of_year
                        let chartIndexPath = IndexPath(item: 4, section: 0)
                        self.tableView?.reloadRows(at: [chartIndexPath], with: .none)
                    }
                }
            }
        }
        
        if let speciesId = speciesId, let coordinate = self.coordinate {
            // refetch the species counts
            // the count we use for the challenges screen is limited to only mobile, and only
            // a few months around the current month. we want the full count on iNat for the stats
            // on this screen.
            let countUrl = "https://api.inaturalist.org/v1/observations/species_counts?lat=\(coordinate.latitude)&lng=\(coordinate.longitude)&radius=50&taxon_id=\(speciesId)"
            Alamofire.request(countUrl).responseData { response in
                if let data = response.result.value {
                    let response = try! JSONDecoder().decode(SpeciesCountResponse.self, from: data)
                    if let results = response.results, results.count > 0 {
                        // just in case we get more than one response, which will happen
                        // if we ever stop being species only
                        for result in results {
                            if result.taxon == self.species {
                                self.obsCountInPlace = result.count                                
                                let obsCountIndexPath = IndexPath(item: 5, section: 0)
                                self.tableView?.reloadRows(at: [obsCountIndexPath], with: .none)
                            }
                        }
                    }
                }
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
            cell.selectionStyle = .none
            
            if cell.scrollView?.delegate == nil {
                cell.scrollView?.delegate = self
            }
            cell.scrollView?.auk.removeAll()
            
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
            
            if let observation = self.observation {
                // need to show collection data
                var baseStr = "Collected"
                if let dateStr = observation.relativeDateString {
                    baseStr.append(" \(dateStr)")
                }
                baseStr.append("!")
                cell.collectedLabel?.text = baseStr
            } else {
                // need to hide colleciton data
                cell.collectedCheck?.isHidden = true
                cell.collectedView?.isHidden = true
                if let view = cell.collectedView {
                    let filteredConstraints = view.constraints.filter { $0.identifier == "collectedViewHeight" }
                    if let height = filteredConstraints.first {
                        height.constant = 0
                    }
                }
            }
            
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
            
            if let species = self.species {
                if let placeName = self.placeName {
                    cell.locationLabel?.text = "Where are people seeing it nearby?"
                } else if self.observation != nil {
                    cell.locationLabel?.text = "Location"
                } else {
                    cell.locationLabel?.text = "Where are people seeing it nearby?"
                }
                
                let template = "https://api.inaturalist.org/v1/colored_heatmap/{z}/{x}/{y}.png?taxon_id=\(species.id)"
                let overlay = MKTileOverlay(urlTemplate: template)
                overlay.tileSize = CGSize(width: 512, height: 512)
                overlay.canReplaceMapContent = false
                cell.mapView?.addOverlays([overlay], level: .aboveRoads)

                if let boundingBox = self.boundingBox {
                    let sw = CLLocationCoordinate2D(latitude: boundingBox.swlat, longitude: boundingBox.swlng)
                    let ne = CLLocationCoordinate2D(latitude: boundingBox.nelat, longitude: boundingBox.nelng)
                    
                    let p1 = MKMapPointForCoordinate(sw)
                    let p2 = MKMapPointForCoordinate(ne)
                    let zoomRect = MKMapRectMake(fmin(p1.x,p2.x), fmin(p1.y,p2.y), fabs(p1.x-p2.x), fabs(p1.y-p2.y))
                    let inset = -zoomRect.size.width * 0.10;
                    cell.mapView?.setVisibleMapRect(MKMapRectInset(zoomRect, inset, inset), animated: false)
                }
                
                if let observation = self.observation {
                    if let coordiante = observation.coordinate {
                        // add a map pin at the area they found it
                        
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
            
            if let histogramData = self.histogramData, let chartView = cell.lineChartView {
                
                let sortedKeys = histogramData.keys.sorted { Int($0)! < Int($1)! }
                
                let max = histogramData.values.max()
                var dataEntry = [ChartDataEntry]()
                for key in sortedKeys {
                    let point = ChartDataEntry(x: Double(sortedKeys.index(of: key)!), y: Double(histogramData[key]!))
                    dataEntry.append(point)
                }
                
                let chartDataSet = LineChartDataSet(values: dataEntry, label: "Observations")
                chartDataSet.drawValuesEnabled = false
                chartDataSet.drawCirclesEnabled = false
                chartDataSet.mode = .cubicBezier
                chartDataSet.cubicIntensity = 0.2
                chartDataSet.colors = [UIColor.white]
                chartDataSet.lineWidth = 3.0
                
                // gradient fill
                let gradientColors = [UIColor.white.cgColor, UIColor.white.withAlphaComponent(0.8).cgColor, UIColor.white.withAlphaComponent(0.3).cgColor] as CFArray
                let colorLocations: [CGFloat] = [1.0, 0.3, 0]
                let colorSpace = CGColorSpaceCreateDeviceRGB()
                if let gradient = CGGradient.init(colorsSpace: colorSpace, colors: gradientColors, locations: colorLocations) {
                    chartDataSet.fill = Fill.fillWithLinearGradient(gradient, angle: 90.0)
                    chartDataSet.drawFilledEnabled = true
                }
                
                chartView.xAxis.labelPosition = .bottom
                chartView.xAxis.drawGridLinesEnabled = false
                chartView.xAxis.labelTextColor = UIColor.white
                if let font = UIFont(name: "Whitney-Book", size: 12) {
                    chartView.xAxis.labelFont = font
                }
                chartView.xAxis.axisLineColor = UIColor.white
                
                chartView.chartDescription?.enabled = false
                chartView.legend.enabled = false
                chartView.rightAxis.enabled = false
                
                chartView.leftAxis.enabled = true
                chartView.leftAxis.drawGridLinesEnabled = false
                chartView.leftAxis.axisMinimum = 0
                chartView.leftAxis.axisMaximum = Double(max! + 2)
                chartView.leftAxis.axisLineColor = UIColor.white
                chartView.leftAxis.labelTextColor = UIColor.white
                if let font = UIFont(name: "Whitney-Book", size: 12) {
                    chartView.leftAxis.labelFont = font
                }
                
                let xAxisLabels = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
                chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: xAxisLabels)
                
                let chartData = LineChartData()
                chartData.addDataSet(chartDataSet)
                chartView.data = chartData
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
}

extension SpeciesDetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.activePhotoAttribution = nil
        
        if let pageIndex = scrollView.auk.currentPageIndex, let species = self.species {
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
