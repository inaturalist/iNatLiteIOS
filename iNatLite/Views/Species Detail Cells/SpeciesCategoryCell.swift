//
//  SpeciesCategoryCell.swift
//  iNatLite
//
//  Created by Alex Shepard on 2/23/18.
//  Copyright © 2018 iNaturalist. All rights reserved.
//

import UIKit

class SpeciesCategoryCell: UITableViewCell {
    
    @IBOutlet var backgroundTop: UIView?
    @IBOutlet var backgroundStripe: UIView?
    @IBOutlet var backgroundBottom: UIView?

    @IBOutlet var categoryLabel: UILabel?
    @IBOutlet var categoryImageView: UIImageView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundTop?.backgroundColor = UIColor.INat.SpeciesNameBackground
        backgroundBottom?.backgroundColor = UIColor.INat.SpeciesDetailBackground

        backgroundStripe?.backgroundColor = UIColor.INat.CategoryBackground
        categoryLabel?.textColor = UIColor.INat.CategoryForeground
        categoryImageView?.tintColor = UIColor.INat.CategoryForeground
    }
}
