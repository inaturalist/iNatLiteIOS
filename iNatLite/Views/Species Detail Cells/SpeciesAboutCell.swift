//
//  SpeciesAboutCell.swift
//  iNatLite
//
//  Created by Alex Shepard on 2/23/18.
//  Copyright © 2018 iNaturalist. All rights reserved.
//

import UIKit

class SpeciesAboutCell: UITableViewCell {
    @IBOutlet var wikipediaTextLabel: UILabel?
    @IBOutlet var aboutLabel: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = UIColor.clear
    }
}
