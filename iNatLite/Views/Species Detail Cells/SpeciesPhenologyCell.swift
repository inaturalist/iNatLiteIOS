//
//  SpeciesPhenologyCell.swift
//  iNatLite
//
//  Created by Alex Shepard on 2/23/18.
//  Copyright © 2018 iNaturalist. All rights reserved.
//

import UIKit
import Charts

class SpeciesPhenologyCell: UITableViewCell {
    
    @IBOutlet var phenologyLabel: UILabel?
    @IBOutlet var lineChartView: LineChartView?
    @IBOutlet var chartBackground: UIView?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = UIColor.clear
        
        chartBackground?.backgroundColor = UIColor.INat.SpeciesPhenlogyBackground
        chartBackground?.layer.cornerRadius = 5.0
        chartBackground?.clipsToBounds = true
        
        lineChartView?.isUserInteractionEnabled = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
