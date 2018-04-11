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
            title = String(format: NSLocalizedString("iNaturalist Observations of %@", comment: "title of screen showing map of observations of a species"), species.displayName)
        }
        
        if let mapView = self.mapView {
            mapView.delegate = self
            
            if let species = self.species,
                let boundingBox = self.boundingBox
            {
                let zoomRect = boundingBox.mapRect()
                let inset = -zoomRect.size.width * 0.10;
                mapView.setVisibleMapRect(MKMapRectInset(zoomRect, inset, inset), animated: false)
                
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
