//
//  UIImage+INatLite.swift
//  iNatLite
//
//  Created by Alex Shepard on 4/5/18.
//  Copyright © 2018 iNaturalist. All rights reserved.
//

import UIKit

extension UIImage {
    static func profileIconForObservationCount(_ count: Int) -> UIImage? {
        if let imageName = UIImage.profileIconNameForObservationCount(count) {
            return UIImage(named: imageName)
        } else {
            return nil
        }
    }
    
    internal static func profileIconNameForObservationCount(_ count: Int) -> String? {
        switch count {
        case _ where count < 0:
            return nil
        case _ where count == 0:
            return "icn-profile-egg"
        case 1:
            return "icn-profile-egg-crack-1"
        case 2:
            return "icn-profile-egg-crack-2"
        case _ where count < 15:
            return "icn-profile-tadpole"
        case _ where count < 35:
            return "icn-profile-cub"
        case _ where count < 65:
            return "icn-profile-surveyor"
        case _ where count < 100:
            return "icn-profile-naturalist"
        case _ where count >= 100:
            return "icn-profile-explorer"
        default:
            return nil
        }
    }
}

