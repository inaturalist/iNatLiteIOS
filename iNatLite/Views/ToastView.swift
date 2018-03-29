//
//  ToastView.swift
//  iNatLite
//
//  Created by Alex Shepard on 2/27/18.
//  Copyright © 2018 iNaturalist. All rights reserved.
//

import UIKit

class ToastView: UIView {
    @IBOutlet var titleLabel: UILabel?
    @IBOutlet var messageLabel: UILabel?
    @IBOutlet var imageView: UIImageView?
    
    class func instanceFromNib() -> ToastView? {
        let nib = UINib(nibName: "ToastView", bundle: Bundle.main)
        if let views = nib.instantiate(withOwner: nil, options: nil) as? [ToastView], let first = views.first {
            return first
        } else {
            return nil
        }
    }
}
