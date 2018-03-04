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
    
    var selectedTaxon: Taxon?
    
    weak var delegate: IconicTaxonPickerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView?.contentInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        //self.collectionView?.backgroundColor = UIColor.INat.DarkBlue
        let gradient = RadialGradientView()
        gradient.insideColor = UIColor.INat.LighterDarkBlue
        gradient.outsideColor = UIColor.INat.DarkBlue
        self.collectionView?.backgroundView = gradient
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
        
        cell.contentView.layer.cornerRadius = 4.0
        cell.clipsToBounds = true
        
        // Configure the cell
        if indexPath.item == 0 {
            cell.imageView?.image = UIImage(named: "icn-iconic-taxa-all")?.withRenderingMode(.alwaysTemplate)
            cell.label?.text = "All"
            
            if self.selectedTaxon == nil {
                cell.contentView.backgroundColor = UIColor.white
                cell.imageView?.tintColor = UIColor.INat.DarkBlue
                cell.label?.textColor = UIColor.INat.DarkBlue
            } else {
                cell.contentView.backgroundColor = UIColor.white.withAlphaComponent(0.07)
                cell.imageView?.tintColor = UIColor.white
                cell.label?.textColor = UIColor.white
            }
        } else {
            let iconicTaxon = Taxon.Iconics[indexPath.item - 1]
            
            if let iconicTaxonImageName = iconicTaxon.iconicImageName() {
                cell.imageView?.image = UIImage(named: iconicTaxonImageName)?.withRenderingMode(.alwaysTemplate)
            }
            cell.label?.text = iconicTaxon.anyNameCapitalized

            if self.selectedTaxon == iconicTaxon {
                cell.contentView.backgroundColor = UIColor.white
                cell.imageView?.tintColor = UIColor.INat.DarkBlue
                cell.label?.textColor = UIColor.INat.DarkBlue
            } else {
                cell.contentView.backgroundColor = UIColor.white.withAlphaComponent(0.07)
                cell.imageView?.tintColor = UIColor.white
                cell.label?.textColor = UIColor.white
            }

            
        }
    
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath)
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
            self.selectedTaxon = nil
        } else {
            self.selectedTaxon = Taxon.Iconics[indexPath.item-1]
        }
        collectionView.reloadData()
        self.delegate?.choseIconicTaxon(self.selectedTaxon)
    }

}
