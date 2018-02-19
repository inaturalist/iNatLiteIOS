//
//  LocationTagCell.swift
//  iNatLite
//
//  Created by Alex Shepard on 2/18/18.
//  Copyright © 2018 iNaturalist. All rights reserved.
//

import UIKit

class LocationTagCell: UICollectionViewCell {
    @IBOutlet var label: UILabel?
    
    override func awakeFromNib() {
        self.contentView.backgroundColor = UIColor.INat.Green
        self.contentView.layer.cornerRadius = 30.5/2
        self.contentView.clipsToBounds = true
    }
}
