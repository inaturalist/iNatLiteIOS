//
//  ResultsImageTaxonCell.swift
//  iNatLite
//
//  Created by Alex Shepard on 2/16/18.
//  Copyright © 2018 iNaturalist. All rights reserved.
//

import UIKit

class ResultsDualImageCell: UITableViewCell {
    
    // left
    @IBOutlet var leadingImageView: UIImageView?
    @IBOutlet var leadingImageLabel: UILabel?
    @IBOutlet var trailingImageView: UIImageView?
    @IBOutlet var trailingImageLabel: UILabel?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        for iv in [leadingImageView, trailingImageView] {
            iv?.layer.cornerRadius = 5.0
            iv?.layer.borderColor = UIColor.white.cgColor
            iv?.layer.borderWidth = 1.0
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
