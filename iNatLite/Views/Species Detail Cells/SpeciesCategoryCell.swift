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
        
        backgroundTop?.backgroundColor = UIColor(named: .SpeciesNameBackground)
        backgroundBottom?.backgroundColor = UIColor(named: .SpeciesDetailBackground)
        
        backgroundStripe?.backgroundColor = UIColor(named: .CategoryBackground)
        categoryLabel?.textColor = UIColor(named: .CategoryForeground)
        categoryImageView?.tintColor = UIColor(named: .CategoryForeground)
    }
}
