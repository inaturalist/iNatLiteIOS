//
//  MyCollectionHeaderView.swift
//  iNatLite
//
//  Created by Alex Shepard on 2/25/18.
//  Copyright © 2018 iNaturalist. All rights reserved.
//

import UIKit

class MyCollectionHeaderView: UICollectionReusableView {
    @IBOutlet var titleLabel: UILabel?
    @IBOutlet var moreButton: UIButton?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = UIColor.INat.MyCollectionBadgesHeaderBackground
    }
}
