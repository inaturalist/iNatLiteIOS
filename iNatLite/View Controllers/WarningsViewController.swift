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
    
    @IBOutlet var goButton: UIButton?
    
    @IBOutlet var checkOne: UILabel?
    @IBOutlet var checkTwo: UILabel?
    @IBOutlet var checkThree: UILabel?
    @IBOutlet var checkFour: UILabel?

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
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
