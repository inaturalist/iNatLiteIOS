//
//  AboutViewController.swift
//  iNatLite
//
//  Created by Alex Shepard on 3/1/18.
//  Copyright © 2018 iNaturalist. All rights reserved.
//

import UIKit

private let madeByCellId = "madeByCellId"
private let userActivityCellId = "userActivityCellId"
private let inatCreditsCellId = "inatCreditsCellId"

class AboutViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("About", comment: "Title of the about screen")

        let imageView = UIImageView(image: UIImage(named: "bg-splash"))
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.tableView.backgroundView = imageView
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.item == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: madeByCellId, for: indexPath) as! MadeByCell
            cell.backgroundColor = .clear
            
            return cell
        } else if indexPath.item == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: userActivityCellId, for: indexPath) 
            cell.backgroundColor = .clear
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: inatCreditsCellId, for: indexPath) 
            cell.backgroundColor = .clear
            
            return cell
        }
    }

}
