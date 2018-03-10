//
//  SplashViewController.swift
//  iNatLite
//
//  Created by Alex Shepard on 3/10/18.
//  Copyright © 2018 iNaturalist. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if let delegate = UIApplication.shared.delegate,
                let window = delegate.window,
                let storyboard = self.storyboard
            {
                let vc = storyboard.instantiateViewController(withIdentifier: "warningsViewController")
                window?.rootViewController = vc
            }
        }
    }
}
