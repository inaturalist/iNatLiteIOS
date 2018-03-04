//
//  SpeciesSeenStatsCell.swift
//  iNatLite
//
//  Created by Alex Shepard on 2/23/18.
//  Copyright © 2018 iNaturalist. All rights reserved.
//

import UIKit

class SpeciesSeenStatsCell: UITableViewCell {
    
    @IBOutlet var seenLabel: UILabel?
    @IBOutlet var inatImageView: UIImageView?
    @IBOutlet var worldwideStatsLabel: UILabel?
    @IBOutlet var localStatsLabel: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.clear
    }
}
