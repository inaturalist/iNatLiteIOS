//
//  INatCreditsCell.swift
//  iNatLite
//
//  Created by Alex Shepard on 3/1/18.
//  Copyright © 2018 iNaturalist. All rights reserved.
//

import UIKit

class INatCreditsCell: UITableViewCell {
    
    @IBOutlet var versionLabel: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()

        versionLabel?.textColor = UIColor.INat.Green
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            versionLabel?.text = String(format: NSLocalizedString("Version %@", comment: "Version number of the app"), version)
        }

    }
}
