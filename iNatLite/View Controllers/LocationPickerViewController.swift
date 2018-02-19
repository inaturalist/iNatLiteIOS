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

private let locationTagCellId = "LocationTagCell"

protocol LocationChooserDelegate: NSObjectProtocol {
    func chosePlace(_ place: Place)
}

class LocationPickerViewController: UIViewController {
    
    @IBOutlet var searchBar: UISearchBar?
    @IBOutlet var collectionView: UICollectionView?
    @IBOutlet var mapView: MKMapView?
    
    weak var delegate: LocationChooserDelegate?

    var nearbyPlaces = [Place]()
    
    // MARK: - UIViewController lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.black
        self.collectionView?.contentInset = UIEdgeInsetsMake(5, 5, 5, 5)

        // need to set estimated size to let the collection view flow layout automatically
        // size the cells
        if let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = CGSize(width: 1, height: 1)
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

extension LocationPickerViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        let center = mapView.userLocation.coordinate;
        let span = MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
        let region = MKCoordinateRegion(center: center, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        // the user is panning or moving the map, clear the list of loaded iNat places
        self.nearbyPlaces.removeAll()
        self.collectionView?.reloadData()
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        self.nearbyPlaces.removeAll()
        self.collectionView?.reloadData()
        
        let mapRect = mapView.visibleMapRect;
        let neMapPoint = MKMapPointMake(MKMapRectGetMaxX(mapRect), mapRect.origin.y)
        let swMapPoint = MKMapPointMake(mapRect.origin.x, MKMapRectGetMaxY(mapRect))
        let neCoord = MKCoordinateForMapPoint(neMapPoint)
        let swCoord = MKCoordinateForMapPoint(swMapPoint)

        let urlString = "https://api.inaturalist.org/v1/places/nearby?nelat=\(neCoord.latitude)&nelng=\(neCoord.longitude)&swlat=\(swCoord.latitude)&swlng=\(swCoord.longitude)"
        
        if let url = URL(string: urlString) {
            Alamofire.request(url).responseData { response in
                print(response)
                if let data = response.result.value {
                    let response = try! JSONDecoder().decode(PlaceNearbyResponse.self, from: data)
                    if let results = response.results {
                        if let standard = results.standard {
                            self.nearbyPlaces.append(contentsOf: standard)
                        }
                        if let community = results.community {
                            self.nearbyPlaces.append(contentsOf: community)
                        }
                        self.collectionView?.reloadData()
                    }
                    
                    print(response)
                }
            }
        }

        print("region changed")
    }
}

extension LocationPickerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let place = self.nearbyPlaces[indexPath.item]
        self.delegate?.chosePlace(place)
    }
}

extension LocationPickerViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.nearbyPlaces.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: locationTagCellId, for: indexPath) as! LocationTagCell
        
        cell.label?.text = "something"
        let place = self.nearbyPlaces[indexPath.item]
        if let name = place.display_name {
            cell.label?.text = name
        } else if place.name != "" {
            cell.label?.text = place.name
        }
        
        return cell
    }
}

