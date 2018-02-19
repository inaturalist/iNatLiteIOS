//
//  SpeciesCollectionViewCell.swift
//  iNatLite
//
//  Created by Alex Shepard on 2/14/18.
//  Copyright © 2018 iNaturalist. All rights reserved.
//

import UIKit
import UIImageViewAlignedSwift

class SpeciesCollectionViewCell: UICollectionViewCell {
    @IBOutlet var photoView: UIImageViewAligned?
    @IBOutlet var nameLabel: UILabel?
    @IBOutlet var nameScrim: UIView?
    
    override func prepareForReuse() {
        photoView?.image = nil
    }
    
    override func awakeFromNib() {
        self.layer.cornerRadius = 5.0
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 1.0
        self.clipsToBounds = true
        
        self.nameScrim?.backgroundColor = UIColor.black.withAlphaComponent(0.2)
    }
}
