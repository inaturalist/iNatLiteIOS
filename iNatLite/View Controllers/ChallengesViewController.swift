//
//  ChallengesViewController.swift
//  iNatLite
//
//  Created by Alex Shepard on 2/14/18.
//  Copyright © 2018 iNaturalist. All rights reserved.
//

import UIKit
import CoreLocation
import FontAwesomeKit
import Alamofire
import Imaginary
import ALCameraViewController
import Gallery
import CropViewController

private let reuseIdentifier = "species"

class ChallengesViewController: UIViewController {
    
    @IBOutlet var collectionView: UICollectionView?
    @IBOutlet var footer: UIView?
    
    @IBOutlet var footerHead: UILabel?
    @IBOutlet var footerLabel: UILabel?
    @IBOutlet var footerPlus: UIButton?

    var locationManager: CLLocationManager?
    var nearbyPlace: Place?
    var chosenPlace: Place?
    var chosenIconicTaxon: Taxon?

    var speciesCounts = [SpeciesCount]()
    
    // MARK: - ibaction targets
    @IBAction func tappedPlus() {
        Gallery.Config.tabsToShow = [.imageTab, .cameraTab]
        Gallery.Config.Camera.imageLimit = 1
        Gallery.Config.Camera.recordLocation = true
        
        let gallery = GalleryController()
        gallery.delegate = self

        let nav = UINavigationController(rootViewController: gallery)        
        // we'll use the delegate to hide the navbar when the camera is up
        // but show it when confirm/crop/results have been pushed onto the
        // navigation stack
        nav.delegate = self
        present(nav, animated: true, completion: nil)
    }
    
    // MARK: - loaders of data from iNat
    func loadSpecies() {
        self.speciesCounts.removeAll()
        self.collectionView?.reloadData()
        
        var urlString: String?
        
        if let place = self.chosenPlace {
            urlString = "https://api.inaturalist.org/v1/observations/species_counts?place_id=\(place.id)&threatened=false&verifiable=true&oauth_application_id=2,3&month=1,2,3&hrank=species"
        } else if let nearby = self.nearbyPlace {
            urlString = "https://api.inaturalist.org/v1/observations/species_counts?place_id=\(nearby.id)&threatened=false&verifiable=true&oauth_application_id=2,3&month=1,2,3&hrank=species"
        }
        
        if let iconicTaxon = self.chosenIconicTaxon {
            urlString?.append("&taxon_id=\(iconicTaxon.id)")
        }
        
        // fetch and repopulate the collection view
        if let urlString = urlString, let url = URL(string: urlString) {
            // Do any additional setup after loading the view.
            Alamofire.request(url).responseData { response in
                if let data = response.result.value {
                    let response = try! JSONDecoder().decode(SpeciesCountResponse.self, from: data)
                    if let speciesCounts = response.results {
                        self.speciesCounts = speciesCounts
                        self.collectionView?.reloadData()
                    }
                }
            }
        }
    }

    
    func loadMyLocation() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse:
            self.locationManager = CLLocationManager()
            self.locationManager?.delegate = self
            self.locationManager?.startUpdatingLocation()
        case .denied, .restricted, .notDetermined:
            self.locationManager = CLLocationManager()
            self.locationManager?.delegate = self
            self.locationManager?.requestWhenInUseAuthorization()
        }
    }

    
    // MARK: - UIViewController lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.INat.DarkBlue
        self.collectionView?.backgroundColor = UIColor.clear
        self.footer?.backgroundColor = UIColor.clear
        
        let nib = UINib(nibName: "SpeciesCollectionView", bundle: Bundle.main)
        self.collectionView?.register(nib, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView?.contentInset = UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0)
        self.collectionView?.delegate = self
        self.collectionView?.dataSource = self
        
        if let head = FAKIonIcons.personIcon(withSize: 40) {
            self.footerHead?.attributedText = head.attributedString()
        }
        
        if let plusCircle = FAKIonIcons.androidAddCircleIcon(withSize: 60),
            let plus = FAKIonIcons.androidAddIcon(withSize: 40)
        {
            plusCircle.addAttribute(NSAttributedStringKey.foregroundColor.rawValue, value: UIColor.INat.Green)
            plus.addAttribute(NSAttributedStringKey.foregroundColor.rawValue, value: UIColor.white)
            
            let image = UIImage(stackedIcons: [plusCircle, plus], imageSize: CGSize(width: 60, height: 60)).withRenderingMode(.alwaysOriginal)
            self.footerPlus?.setImage(image, for: .normal)
        }
        
        self.loadMyLocation()
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToLocationPicker",
            let dest = segue.destination as? LocationPickerViewController
        {
            dest.delegate = self
        } else if segue.identifier == "segueToTaxonPicker",
            let dest = segue.destination as? TaxonPickerViewController
        {
            dest.delegate = self
        }
    }
}

// MARK: - UICollectionViewDataSource
extension ChallengesViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return min(9, self.speciesCounts.count)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! SpeciesCollectionViewCell
        
        let count = self.speciesCounts[indexPath.item]
        cell.nameLabel?.text = count.taxon.anyName
        if let photo = count.taxon.default_photo,
            let urlString = photo.medium_url,
            let url = URL(string: urlString)
        {
            cell.photoView?.setImage(url: url)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as! ChallengesHeaderView
        if let place = self.chosenPlace {
            view.placeButton?.setTitle("\(place.name) ^", for: .normal)
        } else if let place = self.nearbyPlace {
            view.placeButton?.setTitle("\(place.name) ^", for: .normal)
        }
        if let iconicTaxon = self.chosenIconicTaxon {
            view.taxaButton?.setTitle("\(iconicTaxon.anyName) ^", for: .normal)
        } else {
            view.taxaButton?.setTitle("All Species ^", for: .normal)
        }
        view.backgroundColor = UIColor.clear
        return view
    }
}

// MARK: - UICollectionViewDelegate
extension ChallengesViewController: UICollectionViewDelegate {
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ChallengesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let tilesPerRow = 3
        let side = collectionView.frame.size.width / CGFloat(tilesPerRow)
        return CGSize(width: side - 7.5, height: side)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 5.0
    }
}

// MARK: - CLLocationManagerDelegate
extension ChallengesViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            manager.stopUpdatingLocation()
            self.locationManager = nil
            
            let lat = location.coordinate.latitude
            let lng = location.coordinate.longitude
            
            let urlString = "https://api.inaturalist.org/v1/places/nearby?nelat=\(lat)&nelng=\(lng)&swlat=\(lat)&swlng=\(lng)"
            
            if let url = URL(string: urlString) {
                Alamofire.request(url).responseData { response in
                    if let data = response.result.value {
                        let response = try! JSONDecoder().decode(PlaceNearbyResponse.self, from: data)
                        self.nearbyPlace = response.results?.standard?.last
                        if self.nearbyPlace != nil, self.chosenPlace == nil {
                            // show the updated header
                            self.collectionView?.reloadData()
                            // load species for this place
                            self.loadSpecies()
                        }
                    }
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            manager.startUpdatingLocation()
        }
    }
}

extension ChallengesViewController: CropViewControllerDelegate {
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        
        print("cropped image is \(image)")
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "challengeResults") as? ChallengeResultsViewController {
            vc.image = image
            cropViewController.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension  ChallengesViewController: GalleryControllerDelegate {
    func galleryController(_ controller: GalleryController, didSelectImages images: [Gallery.Image]) {
        if let image = images.first {
            image.resolve(completion: { resolvedImage in
                let asset = image.asset
                if let image = resolvedImage {
                    let crop = CropViewController(image: image)
                    crop.rotateButtonsHidden = true
                    crop.aspectRatioPickerButtonHidden = true
                    crop.cancelButtonTitle = "Retake"
                    crop.delegate = self
                    controller.navigationController?.pushViewController(crop, animated: true)
                }
            })
        }
    }
    
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        // not using video
    }
    
    func galleryController(_ controller: GalleryController, requestLightbox images: [Gallery.Image]) {
        // not implemented yet
    }
    
    func galleryControllerDidCancel(_ controller: GalleryController) {
        dismiss(animated: true, completion: nil)
    }
}

extension ChallengesViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if viewController.isKind(of: GalleryController.self) {
            navigationController.setNavigationBarHidden(true, animated: animated)
        } else {
            navigationController.setNavigationBarHidden(false, animated: animated)
        }
    }
}

extension ChallengesViewController: LocationChooserDelegate {
    func chosePlace(_ place: Place) {
        self.chosenPlace = place
        self.loadSpecies()
        self.navigationController?.popToRootViewController(animated: true)
    }
}

extension ChallengesViewController: IconicTaxonPickerDelegate {
    func choseIconicTaxon(_ taxon: Taxon?) {
        self.chosenIconicTaxon = taxon
        self.loadSpecies()
        self.navigationController?.popToRootViewController(animated: true)
    }
}
