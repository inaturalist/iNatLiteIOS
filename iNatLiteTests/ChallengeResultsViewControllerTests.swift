//
//  ChallengeResultsViewControllerTests.swift
//  iNatLiteTests
//
//  Created by Alex Shepard on 3/29/18.
//  Copyright © 2018 iNaturalist. All rights reserved.
//

import XCTest
@testable import iNatLite

class ChallengeResultsViewControllerTests: XCTestCase {
    
    var viewController: ChallengeResultsViewController!
    
    func imageFromFixture() -> UIImage? {
        if let path = Bundle(for: ChallengeResultsViewControllerTests.self).path(forResource: "IMG_0766", ofType: "jpg") {
            return UIImage(contentsOfFile: path)
        } else {
            return nil
        }
    }
    
    override func setUp() {
        super.setUp()
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        viewController = storyboard.instantiateViewController(withIdentifier: "challengeResults") as! ChallengeResultsViewController
        viewController.imageFromUser = self.imageFromFixture()

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
    
    func testFixtureImageExists() {
        XCTAssertNotNil(self.imageFromFixture(), "Image from fixture should not be nil.")
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
        XCTAssertTrue((actionCell?.infoLabel?.text?.contains("some photo tips"))!, "With no target and no match, the info text should contain photo tips. May fail when tested in a non-english locale")
        XCTAssertFalse((actionCell?.infoLabel?.isHidden)!, "With no target and no match, the info label should be visible")
        XCTAssertFalse((actionCell?.actionButton?.isHidden)!, "With no target and no match, the action button should be visible")
        XCTAssertEqual(actionCell?.actionButton?.currentTitle, "Start Over", "With no target and no match, the action button should be a call to start over")
        let actionTarget = actionCell?.actionButton?.actions(forTarget: viewController, forControlEvent: .touchUpInside)?.first
        XCTAssertEqual(actionTarget, "startOverPressed", "With no target and no match, the action button should trigger a call to start over")
    }
    
    func testNoTargetMatch() {
        
    }
    
    func testTargetNoMatch() {
        
    }
    
    func testTargetMatch() {
        
    }
    
    func testTargetMatchDifferentSpecies() {
        
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
