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
    let iconic_taxon_id: Int
    let preferred_common_name: String?
    let default_photo: Photo?
    let wikipedia_summary: String?
    let observations_count: Int?
    
    let rank: String?
    let rank_level: Int?
    
    let taxon_photos: [TaxonPhoto]?
    
    var wikipediaText: String? {
        if let summary = self.wikipedia_summary {
            var str = summary.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
            str.append(" (reference: Wikipedia)")
            return str
        } else {
            return "No additional information."
        }
    }
}

extension Taxon {
    struct Iconic {
        static let Plant = Taxon(name: "Plantae", id: 47126, iconic_taxon_id: 47126, preferred_common_name: NSLocalizedString("Plants", comment: "Plants (category of challenges)"), default_photo: nil, wikipedia_summary: nil, observations_count: nil, rank: nil, rank_level: nil, taxon_photos: nil)
        static let Amphibians = Taxon(name: "Amphibia", id: 20978, iconic_taxon_id: 20978, preferred_common_name: NSLocalizedString("Amphibians", comment: "Amphibians (category of challenges)"), default_photo: nil, wikipedia_summary: nil, observations_count: nil, rank: nil, rank_level: nil, taxon_photos: nil)
        static let Fungi = Taxon(name: "Fungi and lichens", id: 47170, iconic_taxon_id: 47170, preferred_common_name: NSLocalizedString("Fungi", comment: "Fungi (category of challenges)"), default_photo: nil, wikipedia_summary: nil, observations_count: nil, rank: nil, rank_level: nil, taxon_photos: nil)
        static let Fish = Taxon(name: "Actinopterygii", id: 47178, iconic_taxon_id: 47178, preferred_common_name: NSLocalizedString("Fish", comment: "Fish (category of challenges)"), default_photo: nil, wikipedia_summary: nil, observations_count: nil, rank: nil, rank_level: nil, taxon_photos: nil)
        static let Reptiles = Taxon(name: "Reptilia", id: 26036, iconic_taxon_id: 26036, preferred_common_name: NSLocalizedString("Reptiles", comment: "Reptiles (category of challenges)"), default_photo: nil, wikipedia_summary: nil, observations_count: nil, rank: nil, rank_level: nil, taxon_photos: nil)
        static let Arachnids = Taxon(name: "Arachnida", id: 47119, iconic_taxon_id: 47119, preferred_common_name: NSLocalizedString("Arachnids", comment: "Arachnids (category of challenges)"), default_photo: nil, wikipedia_summary: nil, observations_count: nil, rank: nil, rank_level: nil, taxon_photos: nil)
        static let Birds = Taxon(name: "Aves", id: 3, iconic_taxon_id: 3, preferred_common_name: NSLocalizedString("Birds", comment: "Birds (category of challenges)"), default_photo: nil, wikipedia_summary: nil, observations_count: nil, rank: nil, rank_level: nil, taxon_photos: nil)
        static let Insects = Taxon(name: "Insecta", id: 47158, iconic_taxon_id: 47158, preferred_common_name: NSLocalizedString("Insects", comment: "Insects (category of challenges)"), default_photo: nil, wikipedia_summary: nil, observations_count: nil, rank: nil, rank_level: nil, taxon_photos: nil)
        static let Mollusks = Taxon(name: "Mollusca", id: 47115, iconic_taxon_id: 47115, preferred_common_name: NSLocalizedString("Mollusks", comment: "Mollusks (category of challenges)"), default_photo: nil, wikipedia_summary: nil, observations_count: nil, rank: nil, rank_level: nil, taxon_photos: nil)
        static let Mammals = Taxon(name: "Mammalia", id: 40151, iconic_taxon_id: 40151, preferred_common_name: NSLocalizedString("Mammals", comment: "Mammals (category of challenges)"), default_photo: nil, wikipedia_summary: nil, observations_count: nil, rank: nil, rank_level: nil, taxon_photos: nil)
    }
    
    static let Iconics = [Taxon.Iconic.Plant,
                          Taxon.Iconic.Amphibians,
                          Taxon.Iconic.Fungi,
                          Taxon.Iconic.Fish,
                          Taxon.Iconic.Reptiles,
                          Taxon.Iconic.Arachnids,
                          Taxon.Iconic.Birds,
                          Taxon.Iconic.Insects,
                          Taxon.Iconic.Mollusks,
                          Taxon.Iconic.Mammals]
    
    func iconicTaxon() -> Taxon? {
        for iconic in Taxon.Iconics {
            if iconic.id == self.iconic_taxon_id {
                return iconic
            }
        }
        return nil
    }
    
    func iconicImageName() -> String? {
        if let iconic = self.iconicTaxon() {
            return "icn-iconic-taxa-\(iconic.displayName.lowercased())"
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

extension Taxon: TaxonNaming {
    var preferredCommonName: String? {
        return self.preferred_common_name
    }
}

struct TaxonPhoto: Decodable {
    let photo: Photo
}

struct Photo: Decodable {
    let square_url: String?
    let medium_url: String?
    let attribution: String?
    let license_code: String?
}

