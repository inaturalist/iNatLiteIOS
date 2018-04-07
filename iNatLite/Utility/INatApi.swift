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
import JWT

class INatApi {
    
    func scoreImage(_ image: UIImage, coordinate: CLLocationCoordinate2D?, date: Date?, completion: @escaping (ScoreResponse?, Error?) -> Void) {
        if let resized = image.resizedTo(CGSize(width: 299, height: 299)), let imageData = UIImageJPEGRepresentation(resized, 1) {
            let jwtStr = JWT.encode(claims: ["application": "ios"], algorithm: .hs512(AppConfig.visionSekret.data(using: .utf8)!))
            
            let params = postParamsForCoordinate(coordinate, date: date)
            
            self.multiPartPostToUrl("https://api.inaturalist.org/v1/computervision/score_image", data: imageData, params: params, jwtStr: jwtStr, decodable: ScoreResponse.self, completion: completion)
        } else {
            completion(nil, nil)
        }
    }
    
    func fullTaxonForSpeciesId(_ speciesId: Int, completion: @escaping (TaxaResponse?, Error?) -> Void) {
        let url = "https://api.inaturalist.org/v1/taxa/\(speciesId)"
        requestUrl(url, decodable: TaxaResponse.self, completion: completion)
    }
    
    func countsForSpeciesId(_ speciesId: Int, coordinate: CLLocationCoordinate2D, completion: @escaping (SpeciesCountResponse?, Error?) -> Void) {
        let truncatedCoord = coordinate.truncate(places: 2)
        let url = "https://api.inaturalist.org/v1/observations/species_counts?lat=\(truncatedCoord.latitude)&lng=\(truncatedCoord.longitude)&radius=50&taxon_id=\(speciesId)"
        requestUrl(url, decodable: SpeciesCountResponse.self, completion: completion)
    }
    
    func histogramForSpeciesId(_ speciesId: Int, coordinate: CLLocationCoordinate2D?, completion: @escaping (HistogramResponse?, Error?) -> Void) {
        var url = "https://api.inaturalist.org/v1/observations/histogram?taxon_id=\(speciesId)&date_field=observed&interval=month_of_year"
        if let coordinate = coordinate {
            let truncatedCoord = coordinate.truncate(places: 2)
            url.append("&lat=\(truncatedCoord.latitude)&lng=\(truncatedCoord.longitude)&radius=50")
        }
        requestUrl(url, decodable: HistogramResponse.self, completion: completion)
    }
    
    func bboxForSpeciesId(_ speciesId: Int, coordinate: CLLocationCoordinate2D, completion: @escaping (BoundingBoxResponse?, Error?) -> Void) {
        let truncatedCoord = coordinate.truncate(places: 2)
        let url = "https://api.inaturalist.org/v1/observations?lat=\(truncatedCoord.latitude)&lng=\(truncatedCoord.longitude)&radius=50&taxon_id=\(speciesId)&per_page=1&return_bounds=true"
        requestUrl(url, decodable: BoundingBoxResponse.self, completion: completion)
    }
    
    func speciesCountsForPlaceId(_ placeId: Int, months:[Int], iconicTaxonId: Int?, completion: @escaping (SpeciesCountResponse?, Error?) -> Void) {
        let queryItem = URLQueryItem(name: "place_id", value: "\(placeId)")
        speciesCountsForPlaceParams([queryItem], months: months, iconicTaxonId: iconicTaxonId, completion: completion)
    }
    
    func speciesCountsForCoordinate(_ coordinate: CLLocationCoordinate2D, radius: Int, months:[Int], iconicTaxonId: Int?, completion: @escaping (SpeciesCountResponse?, Error?) -> Void) {
        let truncatedCoord = coordinate.truncate(places: 2)
        let queryItems = [URLQueryItem(name: "lat", value: "\(truncatedCoord.latitude)"),
                          URLQueryItem(name: "lng", value: "\(truncatedCoord.longitude)"),
                          URLQueryItem(name: "radius", value: "\(radius)")]
        speciesCountsForPlaceParams(queryItems, months: months, iconicTaxonId: iconicTaxonId, completion: completion)
    }
    
    // MARK: - Internal helper methods
    
    internal func postParamsForCoordinate(_ coordinate: CLLocationCoordinate2D?, date: Date?) -> [String: String] {
        var params = [String: String]()
        if let coordinate = coordinate, CLLocationCoordinate2DIsValid(coordinate) {
            let fuzzedCoordinate = coordinate.truncate(places: 2)
            params["lat"] = "\(fuzzedCoordinate.latitude)"
            params["lng"] = "\(fuzzedCoordinate.longitude)"
        }
        if let date = date {
            params["observed_on"] = "\(date.timeIntervalSince1970)"
        }
        return params
    }
    
    internal func speciesCountsUrlWithPlaceParams(_ placeParams: [URLQueryItem], months:[Int], iconicTaxonId: Int?) -> URL? {
        let baseUrlString = "https://api.inaturalist.org/v1/observations/species_counts?threatened=false&verifiable=true&oauth_application_id=2,3&hrank=species&include_only_vision_taxa=true&not_in_list_id=945029"
        
        guard var components = URLComponents(string: baseUrlString) else {
            return nil
        }
        
        components.queryItems?.append(contentsOf: placeParams)
        
        if months.count > 0 {
            let monthsStr = months.map({ "\($0)"}).joined(separator: ",")
            components.queryItems?.append(URLQueryItem(name: "month", value: monthsStr))
        }
        
        if let iconicTaxonId = iconicTaxonId {
            components.queryItems?.append(URLQueryItem(name: "taxon_id", value: "\(iconicTaxonId)"))
        }
        
        if let url = components.url {
            return url
        } else {
            return nil
        }
    }
    
    internal func speciesCountsForPlaceParams(_ placeParams: [URLQueryItem], months:[Int], iconicTaxonId: Int?, completion: @escaping (SpeciesCountResponse?, Error?) -> Void) {
        
        if let url = self.speciesCountsUrlWithPlaceParams(placeParams, months: months, iconicTaxonId: iconicTaxonId) {
            requestUrl(url, decodable: SpeciesCountResponse.self, completion: completion)
        } else {
            completion(nil, nil)
        }
    }

    internal func requestUrl<T>(_ url: URLConvertible, decodable: T.Type, completion: @escaping (T?, Error?) -> Void) where T : Decodable {
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
    
    internal func multiPartPostToUrl<T>(_ url: URLConvertible, data: Data, params: [String: String]?, jwtStr: String?, decodable: T.Type, completion: @escaping (T?, Error?) -> Void) where T : Decodable {
        
        Alamofire.upload(multipartFormData:{ multipartFormData in
            multipartFormData.append(data, withName: "image", fileName: "file.jpg", mimeType: "image/jpeg")
            if let params = params {
                for (key, value) in params {
                    multipartFormData.append(value.data(using: .utf8)!, withName: key)
                }
            }
        },
                         usingThreshold: UInt64.init(),
                         to: url,
                         method: .post,
                         headers: jwtStr != nil ? ["Authorization": jwtStr!] : nil,
                         encodingCompletion: { encodingResult in
                            switch encodingResult {
                            case .success(let upload, _, _):
                                upload.responseData { responseData in
                                    switch responseData.result {
                                    case .success(let data):
                                        do {
                                            let serverResponse = try JSONDecoder().decode(decodable, from: data)
                                            completion(serverResponse, nil)
                                        } catch let error {
                                            completion(nil, error)
                                        }
                                    case .failure(let error):
                                        completion(nil, error)
                                    }
                                }
                            case .failure(let encodingError):
                                completion(nil, encodingError)
                            }
        })

    }
}
