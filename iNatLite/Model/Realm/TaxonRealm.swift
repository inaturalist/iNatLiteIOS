//
//  TaxonRealm.swift
//  iNatLite
//
//  Created by Alex Shepard on 2/25/18.
//  Copyright © 2018 iNaturalist. All rights reserved.
//

import UIKit
import RealmSwift

class TaxonRealm: Object, TaxonNaming {
    override static func primaryKey() -> String? {
        return "id"
    }

    @objc dynamic var name: String = ""
    @objc dynamic var id: Int = 0
    @objc dynamic var preferredCommonName: String?
    @objc dynamic var defaultPhoto: PhotoRealm?
    @objc dynamic var iconicTaxonId: Int = 0    
}
