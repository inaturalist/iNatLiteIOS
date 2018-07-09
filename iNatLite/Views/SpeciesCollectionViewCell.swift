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
    @IBOutlet var container: UIView?
    
    override func prepareForReuse() {
        photoView?.image = nil
        nameLabel?.text = nil
    }
    
    override func awakeFromNib() {
        container?.layer.cornerRadius = 5.0
        container?.layer.masksToBounds = true

        //container?.clipsToBounds = true
        
        layer.shadowColor = UIColor.black.withAlphaComponent(0.15).cgColor
        layer.shadowOffset = CGSize(width: 2, height: 2)
        layer.shadowRadius = 0
        layer.shadowOpacity = 1.0
        layer.masksToBounds = false
        
        self.nameScrim?.backgroundColor = UIColor(named: .SpeciesChicletLabelBackground)
    }
}
