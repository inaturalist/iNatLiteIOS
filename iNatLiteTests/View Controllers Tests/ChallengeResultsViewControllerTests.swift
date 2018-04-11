//
//  ChallengeResultsViewControllerTests.swift
//  iNatLiteTests
//
//  Created by Alex Shepard on 3/29/18.
//  Copyright © 2018 iNaturalist. All rights reserved.
//

import XCTest
@testable import iNatLite
import RealmSwift

class ChallengeResultsViewControllerTests: XCTestCase {
    
    var viewController: ChallengeResultsViewController!
    
    override func setUp() {
        super.setUp()
        
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        viewController = storyboard.instantiateViewController(withIdentifier: "challengeResults") as! ChallengeResultsViewController
        viewController.imageFromUser = FixtureHelper.imageFromFixture()

        let nav = UINavigationController(rootViewController: viewController)
        UIApplication.shared.keyWindow!.rootViewController = nav
        
        // force all the view delegate methods to be setup
        let _ = nav.view
        let _ = viewController.view
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
        
    func testNotLoaded() {
        viewController.resultsLoaded = false
        viewController.tableView!.reloadData()
        
        XCTAssertEqual(viewController.tableView?.numberOfSections, 1, "Even when not loaded, the challenge results should contain one section.")
        XCTAssertEqual(viewController.tableView?.numberOfRows(inSection: 0), 0, "When not loaded, the challenge results should contain zero rows.")
    }
    
    func testNoTargetNoMatch() {
        viewController.resultScore = nil
        viewController.targetTaxon = nil
        viewController.resultsLoaded = true
        viewController.tableView!.reloadData()
        
        let titleText = viewController.titleCell()!.title!.text!
        XCTAssertTrue(titleText.contains("Hrm"), "With no target and no match, the title should contain Hrm. May fail when tested in a non-english locale")
        
        let dividerCell = viewController.dividerCell()
        let dividerImage = UIImage(named: "icn-results-unknown")
        XCTAssertEqual(dividerImage, dividerCell?.dividerImageView?.image, "With no target and no match, the divider cell should display the unknown image")
        
        XCTAssertNil(viewController.imageTaxonCell(), "With No Target and No Match, the taxon image cell should not be displayed")
        let imageCell = viewController.imageCell()
        XCTAssertNotNil(imageCell, "With no target and no match, the image cell should be displayed")
        // can't seem to test that the image equals the fixture image, perhaps due to resizing/compression?
        XCTAssertNotNil(imageCell?.userImageView?.image, "With no target, image cell should contain an image from the user.")
        
        
        let actionCell = viewController.actionCell()
        XCTAssertTrue((actionCell?.infoLabel?.text?.contains("some photo tips"))!, "With no target and no match, the info text should contain photo tips. May fail when tested in a non-english locale.")
        XCTAssertFalse((actionCell?.actionButton?.isHidden)!, "With no target and no match, the action button should be visible")
        XCTAssertEqual(actionCell?.actionButton?.currentTitle, "Start Over", "With no target and no match, the action button should be a call to start over. May fail when test in a non-english locale.")
        let actionTarget = actionCell?.actionButton?.actions(forTarget: viewController, forControlEvent: .touchUpInside)?.first
        XCTAssertEqual(actionTarget, "startOverPressed", "With no target and no match, the action button should start over")
    }
    
    func testNoTargetMatchNotAlreadySeen() {
        let silkMoth = FixtureHelper.silkMothTaxon()!
        viewController.resultScore = TaxonScore(vision_score: 0.99, frequency_score: 0.99, combined_score: 0.99, taxon: silkMoth)
        viewController.targetTaxon = nil
        viewController.resultsLoaded = true
        viewController.tableView!.reloadData()

        let titleText = viewController.titleCell()!.title!.text!
        XCTAssertTrue(titleText.contains("Sweet"), "With no target but a previously unseen match, the title should contain Sweet. May fail when tested in a non-english locale")
        
        let dividerCell = viewController.dividerCell()
        let dividerImage = UIImage(named: "icn-results-match")
        XCTAssertEqual(dividerImage, dividerCell?.dividerImageView?.image, "With no target but a previously unseen match, the divider cell should display the match image")

        XCTAssertNil(viewController.imageCell(), "With no target but a previously unseen match, the image cell should not be displayed")
        let imageTaxonCell = viewController.imageTaxonCell()
        XCTAssertNotNil(imageTaxonCell, "With no target but a previously unseen match, the image taxon cell should be displayed")
        XCTAssertNotNil(imageTaxonCell?.userImageView?.image, "With no target but a previously unseen match, image cell should contain an image from the user.")
        
        let actionCell = viewController.actionCell()
        XCTAssertNil(actionCell?.infoLabel?.text, "With no target but a previously unseen match, the info text should be nil.")
        XCTAssertFalse((actionCell?.actionButton?.isHidden)!, "With no target but a previously unseen match, the action button should be visible")
        XCTAssertTrue(actionCell!.actionButton!.currentTitle!.contains("Add to Collection"), "With no target but a previously unseen match, the action button should be a call to add to collection. May fail when tested in a non-english locale.")
        let actionTarget = actionCell?.actionButton?.actions(forTarget: viewController, forControlEvent: .touchUpInside)?.first
        XCTAssertEqual(actionTarget, "addToCollection", "With no target but a previously unseen match, the action button should add to collection")
    }
    
    func testNoTargetMatchAlreadySeen() {
        let silkMoth = FixtureHelper.silkMothTaxon()!

        let realm = try! Realm()
        try! realm.write {
            let observation = ObservationRealm()
            observation.date = Date()
            let taxon = TaxonRealm()
            taxon.id = silkMoth.id
            observation.taxon = taxon
            realm.add(observation)
        }
        
        viewController.resultScore = TaxonScore(vision_score: 0.99, frequency_score: 0.99, combined_score: 0.99, taxon: silkMoth)
        viewController.targetTaxon = nil
        viewController.resultsLoaded = true
        viewController.tableView!.reloadData()
        
        let titleText = viewController.titleCell()!.title!.text!
        XCTAssertTrue(titleText.contains("Deja"), "With no target but a previously seen match, the title should contain Deja. May fail when tested in a non-english locale")
        
        let dividerCell = viewController.dividerCell()
        let dividerImage = UIImage(named: "icn-results-match")
        XCTAssertEqual(dividerImage, dividerCell?.dividerImageView?.image, "With no target but a previously seen match, the divider cell should display the match image")
        
        XCTAssertNil(viewController.imageCell(), "With no target but a previously seen match, the image cell should not be displayed")
        let imageTaxonCell = viewController.imageTaxonCell()
        XCTAssertNotNil(imageTaxonCell, "With no target but a previously seen match, the image taxon cell should be displayed")
        XCTAssertNotNil(imageTaxonCell?.userImageView?.image, "With no target but a previously seen match, image cell should contain an image from the user.")
        
        let actionCell = viewController.actionCell()
        XCTAssertTrue((actionCell?.infoLabel?.text?.contains("You collected a photo"))!, "With no target but a previously seen match, the info text should contain a notice that you've already collected it. May fail when tested in a non-english locale.")
        XCTAssertFalse((actionCell?.actionButton?.isHidden)!, "With no target but a previously seen match, the action button should be visible")
        XCTAssertTrue(actionCell!.actionButton!.currentTitle!.contains("OK"), "With no target but a previously seen match, the action button should be OK. May fail when tested in a non-english locale.")
        let actionTarget = actionCell?.actionButton?.actions(forTarget: viewController, forControlEvent: .touchUpInside)?.first
        XCTAssertEqual(actionTarget, "okPressed", "With no target but a previously unseen match, the action button should go back to the home screen.")
    }
    
    func testTargetNoMatch() {
        viewController.targetTaxon = FixtureHelper.soldierFlyTaxon()
        viewController.resultScore = nil
        viewController.resultsLoaded = true
        viewController.tableView!.reloadData()
        
        let titleText = viewController.titleCell()!.title!.text!
        XCTAssertTrue(titleText.contains("Hrm"), "With a target but no match, the title should contain Hrm. May fail when tested in a non-english locale")
        
        let dividerCell = viewController.dividerCell()
        let dividerImage = UIImage(named: "icn-results-mismatch")
        XCTAssertEqual(dividerImage, dividerCell?.dividerImageView?.image, "With a target but no match, the divider cell should display the mismatch image")
        
        
        XCTAssertNil(viewController.imageCell(), "With a target but no match, the image cell should not be displayed")
        let imageTaxonCell = viewController.imageTaxonCell()
        XCTAssertNotNil(imageTaxonCell, "With a target but no match, the image taxon cell should be displayed")
        // can't seem to test that the image equals the fixture image, perhaps due to resizing/compression?
        XCTAssertNotNil(imageTaxonCell?.userImageView?.image, "With a target but no match, image cell should contain an image from the user.")
        
        let actionCell = viewController.actionCell()
        XCTAssertTrue((actionCell?.infoLabel?.text?.contains("photo tips"))!, "With a target but no match, the info text should contain photo tips. May fail when tested in a non-english locale.")
        XCTAssertFalse((actionCell?.actionButton?.isHidden)!, "With a target but no match, the action button should be visible")
        XCTAssertTrue(actionCell!.actionButton!.currentTitle!.contains("Start Over"), "With a target but no match, the action button should be Start Over. May fail when tested in a non-english locale.")
        let actionTarget = actionCell?.actionButton?.actions(forTarget: viewController, forControlEvent: .touchUpInside)?.first
        XCTAssertEqual(actionTarget, "startOverPressed", "With a target but no match, the action button should start over.")
    }
    
    func testTargetMatchNotAlreadySeen() {
        let soldierFly = FixtureHelper.soldierFlyTaxon()!
        viewController.targetTaxon = soldierFly
        viewController.resultScore = TaxonScore(vision_score: 0.99, frequency_score: 0.99, combined_score: 0.99, taxon: soldierFly)
        viewController.resultsLoaded = true
        viewController.tableView!.reloadData()
        
        let titleText = viewController.titleCell()!.title!.text!
        XCTAssertTrue(titleText.contains("Match"), "With a target and a previously unseen match, the title should contain Match. May fail when tested in a non-english locale")
        
        let dividerCell = viewController.dividerCell()
        let dividerImage = UIImage(named: "icn-results-match")
        XCTAssertEqual(dividerImage, dividerCell?.dividerImageView?.image, "With a target and a previously unseen match, the divider cell should display the match image")
        
        XCTAssertNil(viewController.imageCell(), "With a target and a previously unseen match, the image cell should not be displayed")
        let imageTaxonCell = viewController.imageTaxonCell()
        XCTAssertNotNil(imageTaxonCell, "With a target and a previously unseen match, the image taxon cell should be displayed")
        // can't seem to test that the image equals the fixture image, perhaps due to resizing/compression?
        XCTAssertNotNil(imageTaxonCell?.userImageView?.image, "With a target and a previously unseen match, image cell should contain an image from the user.")
        
        let actionCell = viewController.actionCell()
        XCTAssertNil(actionCell?.infoLabel?.text, "With a target and a previously unseen match, the info text should be nil.")
        XCTAssertFalse((actionCell?.actionButton?.isHidden)!, "With a target and a previously unseen match, the action button should be visible")
        XCTAssertTrue(actionCell!.actionButton!.currentTitle!.contains("Add to Collection"), "With a target and a previously unseen match, the action button should be a call to add to collection. May fail when tested in a non-english locale.")
        let actionTarget = actionCell?.actionButton?.actions(forTarget: viewController, forControlEvent: .touchUpInside)?.first
        XCTAssertEqual(actionTarget, "addToCollection", "With a target and a previously unseen match, the action button should add to collection")
    }
    
    // you won't get a target for something you've already seen
    // (altho there should be a test for ^^)
    // so no test for testTargetMatchAlreadySeen
    
    func testTargetDifferentMatchAlreadySeen() {
        let soldierFly = FixtureHelper.soldierFlyTaxon()!
        let silkMoth = FixtureHelper.silkMothTaxon()
        
        let realm = try! Realm()
        try! realm.write {
            let silkMothObservation = ObservationRealm()
            silkMothObservation.date = Date()
            let silkMothTaxonRealm = TaxonRealm()
            silkMothTaxonRealm.id = silkMoth!.id
            silkMothTaxonRealm.name = silkMoth!.name
            silkMothTaxonRealm.preferredCommonName = silkMoth!.preferred_common_name
            silkMothObservation.taxon = silkMothTaxonRealm
            realm.add(silkMothObservation)
        }

        viewController.targetTaxon = soldierFly
        viewController.resultScore = TaxonScore(vision_score: 0.99, frequency_score: 0.99, combined_score: 0.99, taxon: silkMoth!)
        viewController.resultsLoaded = true
        viewController.tableView!.reloadData()
        
        
        let titleText = viewController.titleCell()!.title!.text!
        XCTAssertTrue(titleText.contains("Good Try"), "With a target and a non-target match (previously seen), the title should contain Good Try. May fail when tested in a non-english locale")
        
        let dividerCell = viewController.dividerCell()
        let dividerImage = UIImage(named: "icn-results-mismatch")
        XCTAssertEqual(dividerImage, dividerCell?.dividerImageView?.image, "With a target and a non-target match (previously seen), the divider cell should display the unknown image")

        XCTAssertNil(viewController.imageCell(), "With a target and a non-target match (previously seen), the image cell should not be displayed")
        let imageTaxonCell = viewController.imageTaxonCell()
        XCTAssertNotNil(imageTaxonCell, "With a target and a non-target match (previously seen), the image taxon cell should be displayed")
        // can't seem to test that the image equals the fixture image, perhaps due to resizing/compression?
        XCTAssertNotNil(imageTaxonCell?.userImageView?.image, "With a target and a non-target match (previously seen), image cell should contain an image from the user.")

        let actionCell = viewController.actionCell()
        XCTAssertTrue((actionCell?.infoLabel?.text?.contains("You collected a photo"))!, "With a target and a non-target match (previously seen), the info text should contain a notice that you've already collected it. May fail when tested in a non-english locale.")
        XCTAssertFalse((actionCell?.actionButton?.isHidden)!, "With a target and a non-target match (previously seen), the action button should be visible")
        XCTAssertTrue(actionCell!.actionButton!.currentTitle!.contains("OK"), "With a target and a non-target match (previously seen), the action button should be OK. May fail when tested in a non-english locale.")
        let actionTarget = actionCell?.actionButton?.actions(forTarget: viewController, forControlEvent: .touchUpInside)?.first
        XCTAssertEqual(actionTarget, "okPressed", "With a target and a non-target match (previously seen), the action button should go back to the home screen.")
    }
    
    func testTargetDifferentMatchNotAlreadySeen() {
        let soldierFly = FixtureHelper.soldierFlyTaxon()!
        let silkMoth = FixtureHelper.silkMothTaxon()
        
        viewController.targetTaxon = soldierFly
        viewController.resultScore = TaxonScore(vision_score: 0.99, frequency_score: 0.99, combined_score: 0.99, taxon: silkMoth!)
        viewController.resultsLoaded = true
        viewController.tableView!.reloadData()
        
        
        let titleText = viewController.titleCell()!.title!.text!
        XCTAssertTrue(titleText.contains("Good Try"), "With a target and a non-target match, the title should contain Good Try. May fail when tested in a non-english locale")
        
        let dividerCell = viewController.dividerCell()
        let dividerImage = UIImage(named: "icn-results-mismatch")
        XCTAssertEqual(dividerImage, dividerCell?.dividerImageView?.image, "With a target and a non-target match, the divider cell should display the unknown image")
        
        XCTAssertNil(viewController.imageCell(), "With a target and a non-target match, the image cell should not be displayed")
        let imageTaxonCell = viewController.imageTaxonCell()
        XCTAssertNotNil(imageTaxonCell, "With a target and a non-target match, the image taxon cell should be displayed")
        // can't seem to test that the image equals the fixture image, perhaps due to resizing/compression?
        XCTAssertNotNil(imageTaxonCell?.userImageView?.image, "With a target and a non-target match, image cell should contain an image from the user.")
        
        let actionCell = viewController.actionCell()
        XCTAssertTrue((actionCell?.infoLabel?.text?.contains("You still need to collect"))!, "With a target and a non-target match, the info text should contain a notice that you still need to collect it. May fail when tested in a non-english locale.")
        XCTAssertFalse((actionCell?.actionButton?.isHidden)!, "With a target and a previously unseen match, the action button should be visible")
        XCTAssertTrue(actionCell!.actionButton!.currentTitle!.contains("Add to Collection"), "With a target and a non-target match, the action button should be a call to add to collection. May fail when tested in a non-english locale.")
        let actionTarget = actionCell?.actionButton?.actions(forTarget: viewController, forControlEvent: .touchUpInside)?.first
        XCTAssertEqual(actionTarget, "addToCollection", "With a target and a non-target match, the action button should add to collection")
    }
    
}

extension ChallengeResultsViewController {
    func titleCell() -> ResultsTitleCell? {
        return self.tableView!.cellForRow(at: IndexPath(item: 0, section: 0)) as? ResultsTitleCell
    }
    
    func dividerCell() -> ResultsDividerCell? {
        return self.tableView!.cellForRow(at: IndexPath(item: 1, section: 0)) as? ResultsDividerCell
    }
    
    func imageCell() -> ResultsImageCell? {
        return self.tableView!.cellForRow(at: IndexPath(item: 2, section: 0)) as? ResultsImageCell
    }
    
    func imageTaxonCell() -> ResultsImageTaxonCell? {
        return self.tableView!.cellForRow(at: IndexPath(item: 2, section: 0)) as? ResultsImageTaxonCell
    }
    
    func actionCell() -> ResultsActionCell? {
        return self.tableView!.cellForRow(at: IndexPath(item: 3, section: 0)) as? ResultsActionCell
    }
}
