//
//  TaxonNameExtensions.swift
//  iNatLite
//
//  Created by Alex Shepard on 4/11/18.
//  Copyright © 2018 iNaturalist. All rights reserved.
//

import Foundation

protocol TaxonNaming {
    var preferredCommonName: String? { get }
    var name: String { get }
}

extension TaxonNaming {
    var displayName: String {
        get {
            if let name = preferredCommonName {
                return name.localizedCapitalized
            } else {
                return self.name
            }
        }
    }
}
