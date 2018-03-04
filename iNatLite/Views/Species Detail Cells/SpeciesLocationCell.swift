//
//  SpeciesLocationCell.swift
//  iNatLite
//
//  Created by Alex Shepard on 2/23/18.
//  Copyright © 2018 iNaturalist. All rights reserved.
//

import UIKit
import MapKit

class SpeciesLocationCell: UITableViewCell {
    
    @IBOutlet var mapView: MKMapView?
    @IBOutlet var locationLabel: UILabel?
    @IBOutlet var mapProblemLabel: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = UIColor.clear
        
        // setting this in the storyboard doesn't seem to work
        mapView?.isUserInteractionEnabled = false
        
        mapView?.layer.cornerRadius = 5.0
        mapView?.clipsToBounds = true
    }
}
