//
//  SpeciesNameCell.swift
//  iNatLite
//
//  Created by Alex Shepard on 2/23/18.
//  Copyright © 2018 iNaturalist. All rights reserved.
//

import UIKit

class SpeciesNameCell: UITableViewCell {
    
    @IBOutlet var commonName: UILabel?
    @IBOutlet var scientificNameLabel: UILabel?
    @IBOutlet var scientificName: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.INat.SpeciesNameBackground
    }
}
