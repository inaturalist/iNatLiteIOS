//
//  ResultsActionCell.swift
//  iNatLite
//
//  Created by Alex Shepard on 2/17/18.
//  Copyright © 2018 iNaturalist. All rights reserved.
//

enum ResultsActionButtonStyle {
    case standard
    case strong
}

import UIKit

class ResultsActionCell: UITableViewCell {
    
    @IBOutlet var infoLabel: UILabel?
    @IBOutlet var actionButton: UIButton?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if let actionButton = actionButton {
            actionButton.layer.cornerRadius = actionButton.bounds.size.height / 2
        }
        actionButton?.clipsToBounds = true

        self.setActionButtonStyle(.strong)
    }
    
    func setActionButtonStyle(_ style: ResultsActionButtonStyle) {
        switch style {
        case .standard:
            actionButton?.backgroundColor = UIColor.clear
            actionButton?.tintColor = UIColor.white
            actionButton?.layer.borderColor = UIColor.INat.Green.cgColor
            actionButton?.layer.borderWidth = 2.0
            actionButton?.clipsToBounds = true
        case .strong:
            actionButton?.backgroundColor = UIColor.INat.Green
            actionButton?.tintColor = UIColor.white
            if let font = UIFont(name: "Riffic-Bold", size: 18) {
                actionButton?.titleLabel?.font = font
            }
        }
    }
    

}
