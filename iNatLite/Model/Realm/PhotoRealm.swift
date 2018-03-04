//
//  PhotoRealm.swift
//  iNatLite
//
//  Created by Alex Shepard on 2/25/18.
//  Copyright © 2018 iNaturalist. All rights reserved.
//

import UIKit
import RealmSwift

class PhotoRealm: Object {
    @objc dynamic var squareUrl: String?
    @objc dynamic var mediumUrl: String?
}
