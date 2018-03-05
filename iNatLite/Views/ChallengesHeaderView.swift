//
//  ChallengesHeaderView.swift
//  iNatLite
//
//  Created by Alex Shepard on 2/14/18.
//  Copyright © 2018 iNaturalist. All rights reserved.
//

import UIKit

class ChallengesHeaderView: UICollectionReusableView {
    @IBOutlet var placeButton: UIButton?
    @IBOutlet var taxaButton: UIButton?
    
    override func awakeFromNib() {
        placeButton?.tintColor = UIColor.white
        taxaButton?.tintColor = UIColor.white
        placeButton?.titleLabel?.textAlignment = .natural
    }
}
