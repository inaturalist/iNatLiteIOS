//
//  SpeciesImageCell.swift
//  iNatLite
//
//  Created by Alex Shepard on 2/22/18.
//  Copyright © 2018 iNaturalist. All rights reserved.
//

import UIKit

class SpeciesImageCell: UITableViewCell {
    @IBOutlet var scrollView: UIScrollView?
    @IBOutlet var collectedCheck: UIImageView?
    @IBOutlet var collectedView: UIView?
    @IBOutlet var collectedLabel: UILabel?
    @IBOutlet var photoLicenseButton: UIButton?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.clear
        self.photoLicenseButton?.backgroundColor = UIColor.black.withAlphaComponent(0.44)
        self.photoLicenseButton?.layer.cornerRadius = 27/2
        self.photoLicenseButton?.clipsToBounds = true
    }
}
