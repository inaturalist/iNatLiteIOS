//
//  ResultsDividerCell.swift
//  iNatLite
//
//  Created by Alex Shepard on 2/16/18.
//  Copyright © 2018 iNaturalist. All rights reserved.
//

import UIKit

enum ResultsDividerStyle {
    case match
    case mismatch
    case unknown
}


class ResultsDividerCell: UITableViewCell {
    @IBOutlet var scrim: UIView?
    @IBOutlet var dividerImageView: UIImageView?
    
    func setDividerStyle(_ style: ResultsDividerStyle) {
        switch style {
        case .match:
            dividerImageView?.image = UIImage(named: "icn-results-match")
        case .mismatch:
            dividerImageView?.image = UIImage(named: "icn-results-mismatch")
        case .unknown:
            dividerImageView?.image = UIImage(named: "icn-results-unknown")
        }
    }
}
