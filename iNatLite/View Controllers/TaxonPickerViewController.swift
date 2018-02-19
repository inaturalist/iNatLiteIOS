//
//  TaxonPickerViewController.swift
//  iNatLite
//
//  Created by Alex Shepard on 2/19/18.
//  Copyright © 2018 iNaturalist. All rights reserved.
//

import UIKit

private let iconicTaxonCellId = "IconicTaxonCell"

protocol IconicTaxonPickerDelegate: NSObjectProtocol {
    func choseIconicTaxon(_ taxon: Taxon?)
}

class TaxonPickerViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    weak var delegate: IconicTaxonPickerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView?.contentInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        self.collectionView?.backgroundColor = UIColor.INat.DarkBlue
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }

    // MARK: - UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // 1 for all/world, 1 for each iconic taxon
        return Taxon.Iconics.count + 1
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: iconicTaxonCellId, for: indexPath) as! IconicTaxonCell
        
        cell.contentView.backgroundColor = UIColor.INat.LighterDarkBlue
        cell.contentView.layer.cornerRadius = 5.0
        cell.clipsToBounds = true
        
        // Configure the cell
        if indexPath.item == 0 {
            // all
            cell.imageView?.image = UIImage(named: "icn-iconic-taxa-all")
            cell.label?.text = "All"
        } else {
            let iconicTaxon = Taxon.Iconics[indexPath.item - 1]
            cell.imageView?.image = UIImage(named: iconicTaxon.iconicImageName())
            cell.label?.text = iconicTaxon.anyName
        }
    
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let tilesPerRow = 3
        let side = collectionView.frame.size.width / CGFloat(tilesPerRow)
        return CGSize(width: side - 7.5, height: side)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 5.0
    }


    // MARK: - UICollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            self.delegate?.choseIconicTaxon(nil)
        } else {
            self.delegate?.choseIconicTaxon(Taxon.Iconics[indexPath.item-1])
        }
    }

}
