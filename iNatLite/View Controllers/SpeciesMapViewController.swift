//
//  SpeciesMapViewController.swift
//  iNatLite
//
//  Created by Alex Shepard on 2/25/18.
//  Copyright © 2018 iNaturalist. All rights reserved.
//

import UIKit
import MapKit

class SpeciesMapViewController: UIViewController {
    
    var species: Taxon?
    var boundingBox: BoundingBox?
    
    @IBOutlet var mapView: MKMapView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let species = self.species {
            title = "iNaturalist Observations of \(species.anyNameCapitalized)"
        }
        
        if let mapView = self.mapView {
            mapView.delegate = self
            
            if let species = self.species,
                let boundingBox = self.boundingBox
            {
                let sw = CLLocationCoordinate2D(latitude: boundingBox.swlat, longitude: boundingBox.swlng)
                let ne = CLLocationCoordinate2D(latitude: boundingBox.nelat, longitude: boundingBox.nelng)
                
                let p1 = MKMapPoint(sw)
                let p2 = MKMapPoint(ne)
                let zoomRect = MKMapRect(x: fmin(p1.x,p2.x), y: fmin(p1.y,p2.y), width: fabs(p1.x-p2.x), height: fabs(p1.y-p2.y))
                let inset = -zoomRect.size.width * 0.10;
                mapView.setVisibleMapRect(zoomRect.insetBy(dx: inset, dy: inset), animated: false)
                
                let template = "https://api.inaturalist.org/v1/colored_heatmap/{z}/{x}/{y}.png?taxon_id=\(species.id)"
                let overlay = MKTileOverlay(urlTemplate: template)
                overlay.tileSize = CGSize(width: 512, height: 512)
                overlay.canReplaceMapContent = false
                mapView.addOverlays([overlay], level: .aboveRoads)
            }
        }
    }
}

extension SpeciesMapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        return MKTileOverlayRenderer(tileOverlay: overlay as! MKTileOverlay)
    }
}
