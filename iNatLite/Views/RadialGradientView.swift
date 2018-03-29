//
//  RadialGradientView.swift
//  iNatLite
//
//  Created by Alex Shepard on 2/26/18.
//  Copyright © 2018 iNaturalist. All rights reserved.
//

import UIKit

// The center is #47606A and the outer is #0C2D3B
// the center of it is at about 145pt from the top of the screen
// if that’s super annoying, we could just center it for now

class RadialGradientView: UIView {
    var insideColor: UIColor = UIColor.blue
    var outsideColor: UIColor = UIColor.yellow
    let gradientCenterYOffset: CGFloat = 145.0
    var radiusOfGradient: CGFloat = 345.0
    
    override func draw(_ rect: CGRect) {
        let colors = [insideColor.cgColor, outsideColor.cgColor]
        let gradient = CGGradient(colorsSpace: nil, colors: colors as CFArray, locations: nil)
        if let context = UIGraphicsGetCurrentContext(), let gradient = gradient {
            let centerOfGradient: CGPoint = CGPoint(x: rect.width / 2, y: gradientCenterYOffset)
            
            context.drawRadialGradient(gradient, startCenter: centerOfGradient, startRadius: 0, endCenter: centerOfGradient, endRadius: radiusOfGradient, options: CGGradientDrawingOptions.drawsAfterEndLocation)
        }
    }
}
