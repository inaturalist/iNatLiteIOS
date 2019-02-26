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
import Gallery
import CropViewController
import RealmSwift
import Toast_Swift
import PKHUD

private let hasSeenKey = "hasSeenV1"
private let reuseIdentifier = "species"

class ChallengesViewController: UIViewController {
    
    @IBOutlet var directionsView: UIView?
    @IBOutlet var directionsCheckOne: UILabel?
    @IBOutlet var directionsCheckTwo: UILabel?
    @IBOutlet var directionsCheckThree: UILabel?
    @IBOutlet var directionsLabelOne: UILabel?
    @IBOutlet var directionsLabelTwo: UILabel?
    @IBOutlet var directionsLabelThree: UILabel?
    @IBOutlet var directionsGoButton: UIButton?

    @IBOutlet var gradientBackground: RadialGradientView?
    @IBOutlet var collectionView: UICollectionView?
    
    @IBOutlet var footer: UIView?
    @IBOutlet var footerScrim: UIView?
    @IBOutlet var footerProfileIcon: UIButton?
    @IBOutlet var footerCollectionButton: UIButton?
    @IBOutlet var footerPlus: UIButton?
    
    @IBOutlet var failureTitle: UILabel?
    @IBOutlet var failureMessage: UILabel?
    
    @IBOutlet var activitySpinner: UIActivityIndicatorView?

    var locationManager: CLLocationManager?
    var chosenIconicTaxon: Taxon?
    var locationLookupFailed = false
    var reachabilityManager: Alamofire.NetworkReachabilityManager?
    
    var userLocation: CLLocationCoordinate2D?
    var chosenCoordinate: CLLocationCoordinate2D?
    var placeName: String?

    var speciesCounts = [SpeciesCount]()
    
    var activePhotoLocation: CLLocation?
    var activePhotoDate: Date?
    
    var coordinate: CLLocationCoordinate2D? {
        get {
            if let coord = self.chosenCoordinate {
                return coord
            } else if let coord = self.userLocation {
                return coord
            } else {
                return nil
            }
        }
    }

    
    // MARK: - ibaction targets
    @IBAction func tappedPlus() {
        Gallery.Config.tabsToShow = [.cameraTab, .imageTab]
        Gallery.Config.Camera.imageLimit = 1
        Gallery.Config.Camera.recordLocation = true
        
        let gallery = GalleryController()
        gallery.delegate = self
        
        let nav = UINavigationController(rootViewController: gallery)
        nav.navigationBar.barStyle = .blackTranslucent
        nav.navigationBar.tintColor = .white
        // we'll use the delegate to hide the navbar when the camera is up
        // but show it when confirm/crop/results have been pushed onto the
        // navigation stack
        nav.delegate = self
        self.present(nav, animated: true, completion: nil)
    }
    
    @IBAction func tappedProfile() {
        self.performSegue(withIdentifier: "segueToMyCollection", sender: nil)
    }
    
    @IBAction func tappedSeenV1() {
        UserDefaults.standard.set(true, forKey: hasSeenKey)
        UserDefaults.standard.synchronize()
        UIView.animate(withDuration: 0.3, animations: {
            self.directionsView?.alpha = 0.0
        }) { (done) in
            self.directionsView?.isHidden = true
        }
    }
    
    // MARK: - loaders of data from iNat
    func loadSpecies() {
        self.speciesCounts.removeAll()
        self.collectionView?.reloadData()
        self.activitySpinner?.isHidden = false
        self.activitySpinner?.startAnimating()
        
        var urlString: String?
        
        if let coordinate = self.coordinate {
            urlString = "https://api.inaturalist.org/v1/observations/species_counts?lat=\(coordinate.latitude)&lng=\(coordinate.longitude)&radius=50&threatened=false&verifiable=true&oauth_application_id=2,3&hrank=species&include_only_vision_taxa=true&not_in_list_id=945029"
        } else if locationLookupFailed {
            let usa = Place.Fixed.UnitedStates
            urlString = "https://api.inaturalist.org/v1/observations/species_counts?place_id=\(usa.id)&threatened=false&verifiable=true&oauth_application_id=2,3&hrank=species&include_only_vision_taxa=true&not_in_list_id=945029"
        } else {
            return
        }
        
        // get the a month on either side of the current month
        var months = [Int]()
        let calendar = NSCalendar.current
        if let month = calendar.dateComponents([.month], from: Date()).month {
            if month == 1 {
                months = [12,1,2]
            } else {
                months = [month-1,month,month+1]
            }
        }
        let monthsStr = months.map({ "\($0)"}).joined(separator: ",")
        urlString?.append("&month=\(monthsStr)")

        if let iconicTaxon = self.chosenIconicTaxon {
            urlString?.append("&taxon_id=\(iconicTaxon.id)")
        }
        
        // fetch and repopulate the collection view
        if let urlString = urlString, let url = URL(string: urlString) {
            // Do any additional setup after loading the view.
            Alamofire.request(url).responseData { response in
                switch response.result {
                case .failure(let error):
                    print(error)
                    self.activitySpinner?.isHidden = true
                    self.activitySpinner?.stopAnimating()
                    
                    self.failureTitle?.text = "Bummer"
                    if let font = UIFont(name: "Whitney-Medium", size: 16) {
                        let attrs = INatTextAttrs.attrsForFont(font, lineSpacing: 24, alignment: .center)
                        let msg = NSMutableAttributedString(string: "Unable to load challenges: \(error.localizedDescription)", attributes: attrs)
                        self.failureMessage?.attributedText = msg
                    }
                    self.failureTitle?.isHidden = false
                    self.failureMessage?.isHidden = false
                case .success(let value):
                    
                    do {
                        let response = try JSONDecoder().decode(SpeciesCountResponse.self, from: value)
                        if let speciesCounts = response.results {
                            let realm = try! Realm()
                            let collectedTaxa = realm.objects(TaxonRealm.self)
                            let collectedTaxaIds = collectedTaxa.map({ (taxon) -> Int in
                                return taxon.id
                            })
                            self.speciesCounts = speciesCounts.filter({ (speciesCount) -> Bool in
                                return !collectedTaxaIds.contains(speciesCount.taxon.id)
                            })
                            
                            self.activitySpinner?.isHidden = true
                            self.activitySpinner?.stopAnimating()
                            
                            self.collectionView?.reloadData()
                        }
                    } catch {
                        self.failureTitle?.text = "Bummer"
                        if let font = UIFont(name: "Whitney-Medium", size: 16) {
                            let attrs = INatTextAttrs.attrsForFont(font, lineSpacing: 24, alignment: .center)
                            let msg = NSMutableAttributedString(string: "Unable to load challenges, try again later.", attributes: attrs)
                            self.failureMessage?.attributedText = msg
                        }
                        self.activitySpinner?.isHidden = true
                        self.activitySpinner?.stopAnimating()
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
        case .denied, .restricted:
            self.locationLookupFailed = true
            self.loadSpecies()
        case .notDetermined:
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.recalculateBadges()
        
        let realm = try! Realm()
        let observations = realm.objects(ObservationRealm.self)
        var profileImageName = "icn-profile"
        if observations.count == 0 {
            profileImageName = "icn-profile-egg"
        } else if observations.count == 1 {
            profileImageName = "icn-profile-egg-crack-1"
        } else if observations.count == 2 {
            profileImageName = "icn-profile-egg-crack-2"
        } else if observations.count < 15 {
            profileImageName = "icn-profile-tadpole"
        } else if observations.count < 35 {
            profileImageName = "icn-profile-cub"
        } else if observations.count < 65 {
            profileImageName = "icn-profile-surveyor"
        } else if observations.count < 100 {
            profileImageName = "icn-profile-naturalist"
        } else {
            profileImageName = "icn-profile-explorer"
        }
        
        if let profileImage = UIImage(named: profileImageName)?.withRenderingMode(.alwaysOriginal) {
            self.footerProfileIcon?.setImage(profileImage, for: .normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let spinner = self.activitySpinner {
            spinner.transform = CGAffineTransform.init(scaleX: 3, y: 3)
        }

        if let gradient = self.gradientBackground {
            gradient.insideColor = UIColor.INat.LighterDarkBlue
            gradient.outsideColor = UIColor.INat.DarkBlue
        }
        self.collectionView?.backgroundColor = UIColor.clear
        self.footer?.backgroundColor = UIColor.clear
        self.footerScrim?.backgroundColor = UIColor.INat.ChallengesFooterBackground
        
        let nib = UINib(nibName: "SpeciesCollectionView", bundle: Bundle.main)
        self.collectionView?.register(nib, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView?.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        self.collectionView?.delegate = self
        self.collectionView?.dataSource = self
        
        self.navigationController?.delegate = self
        
        self.reachabilityManager = Alamofire.NetworkReachabilityManager(host: "www.inaturalist.org")
        self.reachabilityManager?.listener = { status in
            if self.speciesCounts.count == 0 {
                self.loadMyLocation()
            }
        }
        self.reachabilityManager?.startListening()
        if let reachability = self.reachabilityManager?.isReachable, !reachability {
            self.loadMyLocation()
        }
        
        if UserDefaults.standard.bool(forKey: hasSeenKey) {
            self.directionsView?.isHidden = true
        } else {
            self.directionsView?.isHidden = false
            self.directionsView?.backgroundColor = UIColor.INat.DarkBlue.withAlphaComponent(0.9)
            for check in [directionsCheckOne, directionsCheckTwo, directionsCheckThree] {
                if let check = check, let checkMark = FAKFontAwesome.checkIcon(withSize: 25) {
                    checkMark.addAttribute(NSAttributedString.Key.foregroundColor.rawValue, value: UIColor.INat.CategoryForeground)
                    check.attributedText = checkMark.attributedString()
                }
            }
            
            for label in [directionsLabelOne, directionsLabelTwo, directionsLabelThree] {
                if let label = label,
                    let initialText = label.text,
                    let font = UIFont(name: "Whitney-Medium", size: 16)
                {
                    let attrs = INatTextAttrs.attrsForFont(font, lineSpacing: 20/16, alignment: .natural)
                    let str = NSAttributedString(string: initialText, attributes: attrs)
                    label.attributedText = str
                }
            }
            
            self.directionsGoButton?.layer.cornerRadius = 20
            self.directionsGoButton?.clipsToBounds = true
            self.directionsGoButton?.tintColor = UIColor.INat.DarkBlue
            self.directionsGoButton?.backgroundColor = .white
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToLocationPicker",
            let dest = segue.destination as? LocationPickerViewController
        {
            dest.delegate = self
            dest.locationName = self.placeName
            dest.userLocation = self.userLocation
            dest.chosenCoordinate = self.coordinate
        } else if segue.identifier == "segueToTaxonPicker",
            let dest = segue.destination as? TaxonPickerViewController
        {
            dest.delegate = self
            dest.selectedTaxon = self.chosenIconicTaxon
        } else if segue.identifier == "segueToSpeciesDetail",
            let dest = segue.destination as? SpeciesDetailViewController,
            let count = sender as? SpeciesCount
        {
            dest.species = count.taxon
            // how does speciesDetail handle this coordinate?
            dest.userPlaceName = self.placeName
            dest.userCoordinate = self.coordinate
            self.navigationController?.navigationBar.barStyle = .blackTranslucent
            self.navigationController?.navigationBar.tintColor = .white
        } else {
            self.navigationController?.navigationBar.barStyle = .default
            self.navigationController?.navigationBar.tintColor = .black
        }
    }
    
    // MARK: - Badges Helper

    func recalculateBadges() -> BadgeRealm? {
        let realm = try! Realm()
        let collected = realm.objects(TaxonRealm.self)
        var lastEarned: BadgeRealm?
        for badge in realm.objects(BadgeRealm.self).filter("earned == false") {
            if badge.iconicTaxonId != 0, badge.count != 0 {
                let filteredCollected = collected.filter("iconicTaxonId == \(badge.iconicTaxonId)")
                if filteredCollected.count >= badge.count {
                    try! realm.write {
                        badge.earned = true
                        badge.earnedDate = Date()
                    }
                    lastEarned = badge
                }
            } else if badge.count != 0 {
                if collected.count >= badge.count {
                    try! realm.write {
                        badge.earned = true
                        badge.earnedDate = Date()
                    }
                    lastEarned = badge
                }
            }
        }
        
        let observations = realm.objects(ObservationRealm.self)
        let earnedBadges = realm.objects(BadgeRealm.self).filter("earned = TRUE")
        let str = "Species: \(observations.count)    Badges: \(earnedBadges.count)"
        self.footerCollectionButton?.setTitle(str, for: .normal)
        return lastEarned
    }
}

// MARK: - UICollectionViewDataSource
extension ChallengesViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.speciesCounts.count == 0, let spinner = self.activitySpinner, spinner.isHidden {
            // if the spinner is hidden but we have no results, tell the user we have no data
            self.failureTitle?.text = "Bummer"
            if let font = UIFont(name: "Whitney-Medium", size: 16) {
                let attrs = INatTextAttrs.attrsForFont(font, lineSpacing: 24, alignment: .center)
                let msg = NSMutableAttributedString(string: "Looks like we're not turning up any species in this area. Please try another location.", attributes: attrs)
                self.failureMessage?.attributedText = msg
            }
            
            self.failureTitle?.isHidden = false
            self.failureMessage?.isHidden = false
        } else {
            self.failureTitle?.isHidden = true
            self.failureMessage?.isHidden = true
        }
        return min(9, self.speciesCounts.count)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! SpeciesCollectionViewCell
        
        let count = self.speciesCounts[indexPath.item]
        cell.nameLabel?.text = count.taxon.anyNameCapitalized
        
        if let photo = count.taxon.default_photo,
            let urlString = photo.medium_url,
            let url = URL(string: urlString)
        {
            cell.photoView?.setImage(url: url)
        }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionHeader {
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as! ChallengesHeaderView
            
            if let downArrow = FAKIonIcons.arrowDownBIcon(withSize: 20) {
                if let placeName = self.placeName {
                    let str = NSMutableAttributedString(string: placeName)
                    str.append(NSAttributedString(string: " "))
                    str.append(downArrow.attributedString())
                    view.placeButton?.setAttributedTitle(str, for: .normal)
                } else if locationLookupFailed {
                    // show usa
                    let str = NSMutableAttributedString(string: Place.Fixed.UnitedStates.name)
                    str.append(NSAttributedString(string: " "))
                    str.append(downArrow.attributedString())
                    view.placeButton?.setAttributedTitle(str, for: .normal)
                } else {
                    // presumably still loading
                    let str = NSMutableAttributedString(string: "Loading...")
                    str.append(NSAttributedString(string: " "))
                    str.append(downArrow.attributedString())
                    view.placeButton?.setAttributedTitle(str, for: .normal)
                }
            }
            
            if let downArrow = FAKIonIcons.arrowDownBIcon(withSize: 12) {
                var taxonFilterName: String
                if let iconicTaxon = self.chosenIconicTaxon {
                    taxonFilterName = "\(iconicTaxon.anyNameCapitalized)"
                } else {
                    taxonFilterName = "All Species"
                }
                let str = NSMutableAttributedString(string: taxonFilterName)
                str.append(NSAttributedString(string: " "))
                str.append(downArrow.attributedString())
                view.taxaButton?.setAttributedTitle(str, for: .normal)
            }
            view.backgroundColor = UIColor.clear
            return view
        } else {
            return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "footer", for: indexPath)
        }
    }
}

// MARK: - UICollectionViewDelegate
extension ChallengesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let count = self.speciesCounts[indexPath.item]
        self.performSegue(withIdentifier: "segueToSpeciesDetail", sender: count)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ChallengesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let tilesPerRow = 3
        let width = (collectionView.frame.size.width / CGFloat(tilesPerRow)) - 21
        return CGSize(width: width, height: width * 1.3)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: 75)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: 100)
    }
 
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 15
    }
}

// MARK: - CLLocationManagerDelegate
extension ChallengesViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            manager.stopUpdatingLocation()
            self.locationManager = nil
            // fuzz the location
            self.userLocation = location.coordinate.truncate(places: 2)
            self.loadSpecies()
            
            if let userLoc = self.userLocation {
                let loc = CLLocation(latitude: userLoc.latitude, longitude: userLoc.longitude)
                CLGeocoder().reverseGeocodeLocation(loc) { (placemarks, error) in
                    if let placemarks = placemarks, let first = placemarks.first {
                        // last aoi seems to give the most useful results in the bay area
                        if let aoi = first.areasOfInterest, let lastAoi = aoi.last {
                            self.placeName = lastAoi
                        } else if let locality = first.locality {
                            self.placeName = locality
                        } else if let name = first.name {
                            self.placeName = name
                        }
                    }
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            manager.startUpdatingLocation()
        } else {
            self.loadSpecies()
        }
    }
}

extension ChallengesViewController: CropViewControllerDelegate {
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "challengeResults") as? ChallengeResultsViewController {
            
            if let detail = self.navigationController?.topViewController as? SpeciesDetailViewController {
                vc.targetTaxon = detail.species
            }

            vc.image = image
            vc.takenLocation = self.activePhotoLocation
            vc.takenDate = self.activePhotoDate
            vc.delegate = self
            cropViewController.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension  ChallengesViewController: GalleryControllerDelegate {
    func galleryController(_ controller: GalleryController, didSelectImages images: [Gallery.Image]) {
        if let image = images.first {
            
            PKHUD.sharedHUD.dimsBackground = true
            PKHUD.sharedHUD.userInteractionOnUnderlyingViewsEnabled = false
            
            HUD.show(.progress, onView: controller.view)
            image.resolveWithError(completion: { (resolvedImage, error) in
                let asset = image.asset
                self.activePhotoDate = asset.creationDate
                self.activePhotoLocation = asset.location
                
                if let image = resolvedImage {
                    HUD.hide()
                    let crop = CropViewController(image: image)
                    crop.rotateButtonsHidden = true
                    crop.aspectRatioPickerButtonHidden = true
                    crop.cancelButtonTitle = "Retake"
                    crop.delegate = self
                    controller.navigationController?.pushViewController(crop, animated: true)
                } else {
                    var errorMsg = "Unable to load image."
                    if let error = error {
                        errorMsg = error.localizedDescription
                    }
                    HUD.flash(HUDContentType.labeledError(title: "Error", subtitle: errorMsg), onView: controller.view, delay: 4.0, completion: nil)
                    
                    // clear the selection
                    for image in controller.cart.images {
                        controller.cart.remove(image)
                    }
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
        } else if viewController.isKind(of: ChallengesViewController.self) {
            navigationController.setNavigationBarHidden(true, animated: animated)
        } else {
            navigationController.setNavigationBarHidden(false, animated: animated)
        }
        
        let item = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
        viewController.navigationItem.backBarButtonItem = item
    }
}

extension ChallengesViewController: LocationChooserDelegate {
    func choseLocation(_ name: String, coordinate: CLLocationCoordinate2D) {
        self.placeName = name
        self.chosenCoordinate = coordinate
        
        self.loadSpecies()
        dismiss(animated: true, completion: nil)
    }
}

extension ChallengesViewController: IconicTaxonPickerDelegate {
    func choseIconicTaxon(_ taxon: Taxon?) {
        self.chosenIconicTaxon = taxon
        self.loadSpecies()
        dismiss(animated: true, completion: nil)
    }
}

extension ChallengesViewController: ChallengeResultsDelegate {
    func addedToCollection(_ taxon: Taxon) {
        
        let lastEarned = self.recalculateBadges()
        
        self.navigationController?.popToRootViewController(animated: false)
        
        dismiss(animated: true) {
            
            // show toast
            if let toast = ToastView.instanceFromNib() {
                
                if let lastEarned = lastEarned {
                    // toast about last earned badge
                    if let imageName = lastEarned.earnedIconName,
                        let image = UIImage(named: imageName)
                    {
                        toast.imageView?.image = image
                    }
                    toast.titleLabel?.text = "\(lastEarned.name) badge earned!"
                } else {
                    // toast about taxon
                    if let imageName = taxon.iconicImageName(),
                    let image = UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate)
                    {
                        toast.imageView?.image = image
                    }
                    toast.titleLabel?.text = "\(taxon.anyNameCapitalized) collected!"
                    toast.imageView?.tintColor = UIColor.INat.SpeciesAddButton
                }
                toast.messageLabel?.text = nil
                toast.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 70)
                toast.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
                self.navigationController?.view.showToast(toast, duration: 2.0, position: .top)
            }
            
            // todo: better animation
            let realm = try! Realm()
            let collectedTaxa = realm.objects(TaxonRealm.self)
            let collectedTaxaIds = collectedTaxa.map({ (taxon) -> Int in
                return taxon.id
            })
            self.speciesCounts = self.speciesCounts.filter({ (speciesCount) -> Bool in
                return !collectedTaxaIds.contains(speciesCount.taxon.id)
            })
            self.collectionView?.reloadData()
        }
    }
}
