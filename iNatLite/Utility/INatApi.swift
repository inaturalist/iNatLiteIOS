//
//  INatApi.swift
//  iNatLite
//
//  Created by Alex Shepard on 3/25/18.
//  Copyright © 2018 iNaturalist. All rights reserved.
//

import CoreLocation
import UIKit
import Alamofire

class INatApi {
    
    func fullTaxonForSpeciesId(_ speciesId: Int, completion: @escaping (TaxaResponse?, Error?) -> Void) {
        let url = "https://api.inaturalist.org/v1/taxa/\(speciesId)"
        self.requestUrl(url, decodable: TaxaResponse.self, completion: completion)        
    }
    
    func countsForSpeciesId(_ speciesId: Int, coordinate: CLLocationCoordinate2D, completion: @escaping (SpeciesCountResponse?, Error?) -> Void) {
        let truncatedCoord = coordinate.truncate(places: 2)
        let url = "https://api.inaturalist.org/v1/observations/species_counts?lat=\(truncatedCoord.latitude)&lng=\(truncatedCoord.longitude)&radius=50&taxon_id=\(speciesId)"
        self.requestUrl(url, decodable: SpeciesCountResponse.self, completion: completion)
    }
    
    func histogramForSpeciesId(_ speciesId: Int, coordinate: CLLocationCoordinate2D?, completion: @escaping (HistogramResponse?, Error?) -> Void) {
        var url = "https://api.inaturalist.org/v1/observations/histogram?taxon_id=\(speciesId)&date_field=observed&interval=month_of_year"
        if let coordinate = coordinate {
            let truncatedCoord = coordinate.truncate(places: 2)
            url.append("&lat=\(truncatedCoord.latitude)&lng=\(truncatedCoord.longitude)&radius=50")
        }
        self.requestUrl(url, decodable: HistogramResponse.self, completion: completion)
    }
    
    func bboxForSpeciesId(_ speciesId: Int, coordinate: CLLocationCoordinate2D, completion: @escaping (BoundingBoxResponse?, Error?) -> Void) {
        let truncatedCoord = coordinate.truncate(places: 2)
        let url = "https://api.inaturalist.org/v1/observations?lat=\(truncatedCoord.latitude)&lng=\(truncatedCoord.longitude)&radius=50&taxon_id=\(speciesId)&per_page=1&return_bounds=true"
        self.requestUrl(url, decodable: BoundingBoxResponse.self, completion: completion)
    }
    
    
    func requestUrl<T>(_ url: URLConvertible, decodable: T.Type, completion: @escaping (T?, Error?) -> Void) where T : Decodable {
        Alamofire.request(url).responseData { response in
            switch response.result {
            case .failure(let error):
                completion(nil, error)
            case .success(let data):
                do {
                    let response = try JSONDecoder().decode(decodable, from: data)
                    completion(response, nil)
                } catch {
                    completion(nil, error)
                }
            }
        }
    }
}
