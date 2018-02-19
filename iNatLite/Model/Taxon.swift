//
//  Taxon.swift
//  iNatLite
//
//  Created by Alex Shepard on 2/14/18.
//  Copyright © 2018 iNaturalist. All rights reserved.
//

import Foundation

struct Taxon: Decodable {
    let name: String
    let id: Int
    let preferred_common_name: String?
    let default_photo: TaxonPhoto?
    let wikipedia_summary: String?
    let observations_count: Int?
    
    let rank: String?
    let rank_level: Int?
    
    var anyName: String {
        get {
            if let name = preferred_common_name {
                return name
            } else {
                return self.name
            }
        }
    }
    
    var wikipediaText: String? {
        return self.wikipedia_summary?.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }
    
    var wikipediaHtml: NSAttributedString? {
        if let summary = self.wikipedia_summary, let data = summary.data(using: .utf8) {
            let opts: [NSAttributedString.DocumentReadingOptionKey : Any] = [.documentType: NSAttributedString.DocumentType.html,
                                                                             .characterEncoding: String.Encoding.utf8.rawValue]
            let str = try! NSAttributedString(data: data, options: opts, documentAttributes: nil)
            return str
            //return NSAttributedString(data: data, options: nil, documentAttributes: nil)
        } else {
            return nil
        }
    }
}

extension Taxon: Equatable {
    static func == (lhs: Taxon, rhs: Taxon) -> Bool {
        return lhs.id == rhs.id
    }
}

struct TaxonPhoto: Decodable {
    let square_url: String?
    let medium_url: String?
}

