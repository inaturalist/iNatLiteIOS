//
//  LocationPickerViewController.swift
//  iNatLite
//
//  Created by Alex Shepard on 2/18/18.
//  Copyright © 2018 iNaturalist. All rights reserved.
//

import UIKit
import MapKit
import Alamofire
import FontAwesomeKit

private let locationTagCellId = "LocationTagCell"

protocol LocationChooserDelegate: NSObjectProtocol {
    func choseLocation(_ name: String, coordinate: CLLocationCoordinate2D)
}

class LocationPickerViewController: UIViewController {
    
    var shouldAutoZoomToUserLocation = true
    var locationName: String?
    var coordinate: CLLocationCoordinate2D?
    
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
        }
    }
    
    @IBAction func gotoCurrentLocationPressed() {
        if let map = self.mapView {
            if let userLoc = mapView?.userLocation.coordinate {
                let span = MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
                let region = MKCoordinateRegion(center: userLoc, span: span)
                map.setRegion(region, animated: true)
            }
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
        
        if let coord = self.coordinate, CLLocationCoordinate2DIsValid(coord) {
            shouldAutoZoomToUserLocation = false
            if let map = self.mapView {
                let span = MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
                let region = MKCoordinateRegion(center: coord, span: span)
                map.setRegion(region, animated: false)
            }
        } else {
            lookingLabel?.text = "Looking for species in:"
            locationLabel?.text = Place.Fixed.UnitedStates.name
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

    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if shouldAutoZoomToUserLocation {
            let center = mapView.userLocation.coordinate;
            let span = MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
            let region = MKCoordinateRegion(center: center, span: span)
            mapView.setRegion(region, animated: true)
            shouldAutoZoomToUserLocation = false
        }
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        // the user is panning or moving the map, clear the shown name
        // don't empty it so the UI stays fixed
        locationLabel?.text = " "
        lookingLabel?.text = "Looking for species in a 50 mile radius around this point:"
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        // get center coordinate
        let center = mapView.centerCoordinate
        let location = CLLocation(latitude: center.latitude, longitude: center.longitude)
        
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

