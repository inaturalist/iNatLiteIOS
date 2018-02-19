//
//  ResultsActionCell.swift
//  iNatLite
//
//  Created by Alex Shepard on 2/17/18.
//  Copyright © 2018 iNaturalist. All rights reserved.
//

import UIKit

class ResultsActionCell: UITableViewCell {
    
    @IBOutlet var infoLabel: UILabel?
    @IBOutlet var actionButton: UIButton?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
