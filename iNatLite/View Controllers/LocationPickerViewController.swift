//
//  LocationPickerViewController.swift
//  iNatLite
//
//  Created by Alex Shepard on 2/18/18.
//  Copyright © 2018 iNaturalist. All rights reserved.
//

import UIKit
import MapKit
import FontAwesomeKit

private let locationTagCellId = "LocationTagCell"

protocol LocationChooserDelegate: NSObjectProtocol {
    func choseLocation(_ name: String, coordinate: CLLocationCoordinate2D)
}

class LocationPickerViewController: UIViewController {
    
    var locationName: String?
    var chosenCoordinate: CLLocationCoordinate2D?
    var truncatedUserCoordinate: CLLocationCoordinate2D?
    
    @IBOutlet var mapView: MKMapView?
    @IBOutlet var lookingLabel: UILabel?
    @IBOutlet var locationLabel: UILabel?
    @IBOutlet var locationView: UIView?
    @IBOutlet var centerPin: UILabel?
    @IBOutlet var doneView: UIView?
    @IBOutlet var doneButton: UIButton?
    @IBOutlet var gotoCurrentLocationButton: UIButton?
    @IBOutlet var gradient: RadialGradientView?
    
    weak var delegate: LocationChooserDelegate?
    
    @IBAction func donePressed() {
        if let name = self.locationName, let map = self.mapView {
            self.delegate?.choseLocation(name, coordinate: map.centerCoordinate)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func gotoCurrentLocationPressed() {
        if let userLoc = self.truncatedUserCoordinate, let map = self.mapView {
            let span = MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
            let region = MKCoordinateRegion(center: userLoc, span: span)
            map.setRegion(region, animated: true)
        } else {
            let alertTitle = NSLocalizedString("Sorry", comment: "Title of sorry alert")
            let alertMsg = NSLocalizedString("Unable to determine your location.", comment: "Message of alert when we can't find your location")
            let okButtonTitle = NSLocalizedString("OK", comment: "OK button title")
            let alert = UIAlertController(title: alertTitle, message: alertMsg, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: okButtonTitle, style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - UIViewController lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let gradient = self.gradient {
            gradient.insideColor = UIColor.INat.LighterDarkBlue
            gradient.outsideColor = UIColor.INat.DarkBlue
        }
        
        locationLabel?.text = " "
        locationView?.backgroundColor = UIColor.clear
        doneView?.backgroundColor = UIColor.clear
        doneButton?.backgroundColor = UIColor.INat.Green
        doneButton?.layer.cornerRadius = 40 / 2
        doneButton?.clipsToBounds = true
        
        if let coord = self.chosenCoordinate, CLLocationCoordinate2DIsValid(coord) {
            if let map = self.mapView {
                let span = MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
                let region = MKCoordinateRegion(center: coord, span: span)
                map.setRegion(region, animated: false)
            }
        } else if let coord = self.truncatedUserCoordinate, CLLocationCoordinate2DIsValid(coord) {
            if let map = self.mapView {
                let span = MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
                let region = MKCoordinateRegion(center: coord, span: span)
                map.setRegion(region, animated: false)
            }
        } else {
            lookingLabel?.text = NSLocalizedString("Looking for species in:", comment: "Title for location picker. Below this text is a large label with the place name")
            locationLabel?.text = Place.Fixed.UnitedStates.name
        }
        
        if let locationName = self.locationName {
            self.locationLabel?.text = locationName
        }
        
        if let pin = FAKIonIcons.iosLocationIcon(withSize: 64) {
            pin.addAttribute(NSAttributedStringKey.foregroundColor.rawValue, value: UIColor.INat.Green)
            centerPin?.attributedText = pin.attributedString()
        }
        
        if let navigate = FAKIonIcons.iosNavigateIcon(withSize: 64),
            let navigateOutline = FAKIonIcons.iosNavigateOutlineIcon(withSize: 64)
        {
            navigate.addAttribute(NSAttributedStringKey.foregroundColor.rawValue, value: UIColor.gray)
            navigateOutline.addAttribute(NSAttributedStringKey.foregroundColor.rawValue, value: UIColor.white)
            let nav = UIImage(stackedIcons: [navigate, navigateOutline], imageSize: CGSize(width: 64, height: 64)).withRenderingMode(.alwaysOriginal)
            gotoCurrentLocationButton?.setImage(nav, for: .normal)
        }
    }


}

extension LocationPickerViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        // the user is panning or moving the map, clear the shown name
        // don't empty it so the UI stays fixed
        locationLabel?.text = " "
        lookingLabel?.text = NSLocalizedString("Looking for species in a 50 mile radius around this point:", comment: "The app currently uses US miles.")
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        // get center coordinate
        let center = mapView.centerCoordinate
        let location = CLLocation(latitude: center.latitude,
                                  longitude: center.longitude)
        
        let centerOfUSA = CLLocation(latitude: 37.132840000000016,
                                     longitude: -95.785580000000024)
        
        // don't reverse geocode from exact center of the map
        // TODO: if you live in Independence, USA, this probably sucks
        if location.distance(from: centerOfUSA) < 100 {
            return
        }
        
        CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) in
            if let placemarks = placemarks, let first = placemarks.first {
                // last aoi seems to give the most useful results in the bay
                // area at least
                if let aoi = first.areasOfInterest, let lastAoi = aoi.last {
                    self.locationName = lastAoi
                } else if let locality = first.locality {
                    self.locationName = locality
                } else if let name = first.name {
                    self.locationName = name
                }
                self.locationLabel?.text = self.locationName
            }
        }
    }
}

