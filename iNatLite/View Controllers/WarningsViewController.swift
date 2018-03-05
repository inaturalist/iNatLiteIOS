//
//  WarningsViewController.swift
//  iNatLite
//
//  Created by Alex Shepard on 3/1/18.
//  Copyright © 2018 iNaturalist. All rights reserved.
//

import UIKit
import FontAwesomeKit

class WarningsViewController: UIViewController {
    
    @IBOutlet var mainStack: UIStackView?
    
    @IBOutlet var welcomeLabel: UILabel?
    @IBOutlet var subtitleLabel: UILabel?
    @IBOutlet var legalLabel: UILabel?
    
    @IBOutlet var goButton: UIButton?
    
    @IBOutlet var checkOne: UILabel?
    @IBOutlet var checkTwo: UILabel?
    @IBOutlet var checkThree: UILabel?
    @IBOutlet var checkFour: UILabel?
    
    @IBOutlet var labelOne: UILabel?
    @IBOutlet var labelTwo: UILabel?
    @IBOutlet var labelThree: UILabel?
    @IBOutlet var labelFour: UILabel?


    @IBAction func goButtonPressed() {
        if let delegate = UIApplication.shared.delegate,
            let window = delegate.window,
            let storyboard = self.storyboard
        {
            let vc = storyboard.instantiateViewController(withIdentifier: "challengesNav")
            window?.rootViewController = vc
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // if it's an iphone 5s or se, we need to adjust constraints
        if self.view.bounds.size.width == 320 {
            var filteredConstraints = self.view.constraints.filter { $0.identifier == "stackLeading" }
            if let leading = filteredConstraints.first {
                leading.constant = 10
            }
            filteredConstraints = self.view.constraints.filter { $0.identifier == "stackTrailing" }
            if let trailing = filteredConstraints.first {
                trailing.constant = 10
            }
            self.view.setNeedsLayout()
        }
        
        for check in [checkOne, checkTwo, checkThree, checkFour] {
            if let check = check, let checkMark = FAKFontAwesome.checkIcon(withSize: 25) {
                checkMark.addAttribute(NSAttributedStringKey.foregroundColor.rawValue, value: UIColor.INat.Green)
                check.attributedText = checkMark.attributedString()
            }
        }
        
        if let go = goButton {
            go.layer.cornerRadius = 20
            go.clipsToBounds = true
            go.backgroundColor = .white
        }
        
        if let subtitleLabel = self.subtitleLabel,
            let initialText = subtitleLabel.text,
            let font = UIFont(name: "Whitney-Medium", size: 20)
        {
            let attrs = INatTextAttrs.attrsForFont(font, lineSpacing: 27/20, alignment: .natural)
            let str = NSAttributedString(string: initialText, attributes: attrs)
            subtitleLabel.attributedText = str
        }
        
        if let legalLabel = self.legalLabel,
            let initialText = legalLabel.text,
            let font = UIFont(name: "Whitney-Medium", size: 14)
        {
            let attrs = INatTextAttrs.attrsForFont(font, lineSpacing: 18/14, alignment: .natural)
            let str = NSAttributedString(string: initialText, attributes: attrs)
            legalLabel.attributedText = str
        }
        
        for label in [labelOne, labelTwo, labelThree, labelFour] {
            if let label = label,
                let initialText = label.text,
                let font = UIFont(name: "Whitney-Medium", size: 16)
            {
                let attrs = INatTextAttrs.attrsForFont(font, lineSpacing: 18/16, alignment: .natural)
                let str = NSAttributedString(string: initialText, attributes: attrs)
                label.attributedText = str
            }
        }

    }
}
