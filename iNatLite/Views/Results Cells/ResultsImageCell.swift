//
//  ResultsImageCell.swift
//  iNatLite
//
//  Created by Alex Shepard on 2/16/18.
//  Copyright © 2018 iNaturalist. All rights reserved.
//

import UIKit

class ResultsImageCell: UITableViewCell {
    
    @IBOutlet var userImageView: UIImageView?
    @IBOutlet var userLabel: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userImageView?.layer.cornerRadius = 5.0
        userImageView?.layer.borderColor = UIColor.white.cgColor
        userImageView?.layer.borderWidth = 1.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
