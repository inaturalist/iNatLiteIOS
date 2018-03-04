//
//  MadeByCell.swift
//  iNatLite
//
//  Created by Alex Shepard on 3/1/18.
//  Copyright © 2018 iNaturalist. All rights reserved.
//

import UIKit

class MadeByCell: UITableViewCell {
    
    @IBOutlet var backyardContainer: UIView?
    
    override func awakeFromNib() {
        super.awakeFromNib()

        backyardContainer?.backgroundColor = UIColor.black.withAlphaComponent(0.17)
        backyardContainer?.layer.cornerRadius = 4.0
        backyardContainer?.clipsToBounds = true
    }
}
