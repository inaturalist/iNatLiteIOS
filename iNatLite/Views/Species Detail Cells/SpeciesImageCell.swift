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
        
        backgroundColor = UIColor.clear
        
        photoLicenseButton?.backgroundColor = UIColor.black.withAlphaComponent(0.44)
        photoLicenseButton?.layer.cornerRadius = 27/2
        photoLicenseButton?.clipsToBounds = true
    }
    
    func hideCollectedUI() {
        photoLicenseButton?.isHidden = false
        collectedCheck?.isHidden = true
        
        if let view = collectedView {
            let filteredConstraints = view.constraints.filter { $0.identifier == "collectedViewHeight" }
            if let height = filteredConstraints.first {
                height.constant = 0
                self.layoutIfNeeded()
            }
        }
    }
    
    func showCollectedUI() {
        photoLicenseButton?.isHidden = true
        collectedCheck?.isHidden = false
        
        if let view = collectedView {
            let filteredConstraints = view.constraints.filter { $0.identifier == "collectedViewHeight" }
            if let height = filteredConstraints.first {
                height.constant = 42
                self.layoutIfNeeded()
            }
        }
    }
    
}
