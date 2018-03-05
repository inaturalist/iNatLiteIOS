//
//  NSAttributedString+INatLite.swift
//  iNatLite
//
//  Created by Alex Shepard on 3/4/18.
//  Copyright © 2018 iNaturalist. All rights reserved.
//

import Foundation
import UIKit

struct INatTextAttrs {
    
    static func attrsForFont(_ font: UIFont, lineSpacing: CGFloat, alignment: NSTextAlignment) -> [NSAttributedStringKey: Any] {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.alignment = alignment
        let attrs: [NSAttributedStringKey: Any] = [.font: font,
                                                   .paragraphStyle: paragraphStyle]
        return attrs
    }
}
