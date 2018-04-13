//
//  ChallengeResults.swift
//  iNatLite
//
//  Created by Alex Shepard on 4/12/18.
//  Copyright © 2018 iNaturalist. All rights reserved.
//

import Foundation
import RealmSwift

// this class manages the state engine for challenge results

class ChallengeResults {
    var targetTaxon: Taxon?
    var resultScore: TaxonScore?
    var commonAncestor: TaxonScore?
    
    var resultsLoaded = false
    
    var seenTaxaIds: [Int] {
        get {
            let realm = try! Realm()
            let observations = realm.objects(ObservationRealm.self)
            return observations.filter { return $0.taxon != nil }.map { return $0.taxon!.id }
        }
    }
    
    func dividerStyle() -> ResultsDividerStyle {
        if let score = self.resultScore {
            if let target = self.targetTaxon {
                if target == score.taxon {
                    // you found your target
                    return .match
                } else {
                    // you found something other than what you were looking for
                    return .mismatch
                }
            } else {
                // you found a match, and had no target
                return .match
            }
        } else {
            if let _ = self.targetTaxon {
                // you had a target, and found nothing
                return .mismatch
            } else {
                // you had no target, and found nothing
                return .unknown
            }
        }
    }
    
    func title() -> String {
        if let score = self.resultScore {
            if let target = self.targetTaxon {
                if target == score.taxon {
                    // you found your target
                    return NSLocalizedString("It's a Match!", comment: "Title when the user has found the species they were challenged with.")
                } else {
                    // you found something else
                    return NSLocalizedString("Good Try!", comment: "Title when the user has found a different species than they one they were challenged with.")
                }
            } else {
                if self.seenTaxaIds.contains(score.taxon.id) {
                    return NSLocalizedString("Deja Vu!", comment: "Title when the user has found a species that they've already seen.")
                } else {
                    return NSLocalizedString("Sweet!", comment: "Title when the user has found a new species (without having been given a challenge).")
                }
            }
        } else {
            return NSLocalizedString("Hrmmmmmm", comment: "Title when we can't figure out what species is in the user's photo.")
        }
    }
    
    func subtitle() -> String {
        if let score = self.resultScore {
            if let target = self.targetTaxon {
                if target == score.taxon {
                    // you found your target
                    return String(format: NSLocalizedString("You saw a %@.", comment: "Notice telling the user what species they saw."), score.taxon.displayName)
                } else {
                    // you found something else
                    return String(format: NSLocalizedString("However, this isn't a %@, it's a %@.", comment: "Notice telling the user that they've found a different species than the one they were challenged with. First subtitution is the target/challenge species, second substitution is the actual found species."), target.displayName, score.taxon.displayName)
                }
            } else {
                if self.seenTaxaIds.contains(score.taxon.id) {
                    return String(format: NSLocalizedString("Looks like you already collected a %@.", comment: "Notice telling the user that they've already seen this species."), score.taxon.displayName)
                } else {
                    return String(format: NSLocalizedString("You saw a %@.", comment: "Notice telling the user what species they saw."), score.taxon.displayName)
                }
            }
        } else {
            if let ancestor = self.commonAncestor {
                return String(format: NSLocalizedString("We think this is a photo of %@, but we can't say for sure what species it is.", comment: "Notice when we have only a rough idea of what's in the user's photo."), ancestor.taxon.displayName)
            } else {
                return NSLocalizedString("We can't figure this one out. Please try some adjustments.", comment: "Notice when we have no idea what's in the user's photo.")
            }
        }
    }
    
    func dualImageLeadingLabelText() -> String? {
        if let score = self.resultScore {
            return String(format: NSLocalizedString("Your Photo:\n%@", comment: "Title of the user photo. The substition is the species name in their photo."), score.taxon.displayName)
        } else {
            return NSLocalizedString("Your Photo", comment: "Title of the user photo, when we don't have a species for it.")
        }
    }
    
    func dualImageTrailingLabelText() -> String? {
        if let target = self.targetTaxon {
            return String(format: NSLocalizedString("Target Species:\n%@", comment: "Title of the target species photo. The substition is the target species name."), target.displayName)
        } else if let score = self.resultScore {
            return String(format: NSLocalizedString("Identified Species:\n%@", comment: "Title of the identified species photo. The substition is the identified species name."), score.taxon.displayName)
        } else {
            return nil
        }
    }
    
    func urlForTrailingImageView() -> URL? {
        if let target = self.targetTaxon {
            // show the target taxon photo
            if let photo = target.default_photo,
                let urlString = photo.medium_url,
                let url = URL(string: urlString)
            {
                return url
            }
        } else if let score = self.resultScore {
            // show the identified taxon photo
            if let photo = score.taxon.default_photo,
                let urlString = photo.medium_url,
                let url = URL(string: urlString)
            {
                return url
            }
        }
        return nil
    }
    
    func infoLabelText() -> String? {
        if let result = self.resultScore {
            if self.seenTaxaIds.contains(result.taxon.id) {
                // already seen it, fetch their seen observation
                if let observation = self.seenObservationWithTaxonId(result.taxon.id),
                    let obsTaxon = observation.taxon,
                    let obsDate = observation.dateString
                {
                    return String(format: NSLocalizedString("You collected a photo of a %@ on %@", comment: "Notice about when the user collected a species photo. First subtitution is the species name, second substitution is the locally formatted date."), obsTaxon.displayName, obsDate)
                } else {
                    return nil
                }
            } else {
                if let target = self.targetTaxon {
                    if target == result.taxon {
                        return nil
                    } else {
                        return String(format: NSLocalizedString("You still need to collect a %@. Would you like to collect it now?", comment: "Notice about when the user still needs to collect a species, the substition is the species name."), result.taxon.displayName)
                    }
                } else {
                    return nil
                }
            }
        } else {
            // show tips
            return NSLocalizedString("Here are some photo tips:\nGet as close as possible while being safe\nCrop out unimportant parts\nMake sure things are in focus", comment: "take better photo tips")
        }
    }
    
    func actionButtonStyle() -> ResultsActionButtonStyle {
        if let result = self.resultScore {
            if self.seenTaxaIds.contains(result.taxon.id) {
                return .standard
            } else {
                if let target = self.targetTaxon {
                    if target == result.taxon {
                        return .strong
                    } else {
                        return .standard
                    }
                } else {
                    return .strong
                }
            }
        } else {
            return .standard
        }
    }
    
    func actionButtonTitle() -> String {
        if let result = self.resultScore {
            if self.seenTaxaIds.contains(result.taxon.id) {
                return NSLocalizedString("OK", comment: "OK button title")
            } else {
                return NSLocalizedString("Add to Collection", comment: "add species to your collection button title")
            }
        } else {
            return NSLocalizedString("Start Over", comment: "start species identification over button title")
        }
    }
    
    func actionButtonSelector() -> Selector {
        if let result = self.resultScore {
            if self.seenTaxaIds.contains(result.taxon.id) {
                return #selector(ChallengeResultsViewController.okPressed)
            } else {
                return #selector(ChallengeResultsViewController.addToCollection)
            }
        } else {
            return #selector(ChallengeResultsViewController.startOverPressed)
        }
    }
    
    func seenObservationWithTaxonId(_ taxonId: Int) -> ObservationRealm? {
        let realm = try! Realm()
        let observations = realm.objects(ObservationRealm.self)
        return observations.first(where: { (observation) -> Bool in
            if let taxon = observation.taxon {
                return taxon.id == taxonId
            } else {
                return false
            }
        })
    }
}
