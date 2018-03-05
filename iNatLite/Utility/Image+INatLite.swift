//
//  Image+INatLite.swift
//  iNatLite
//
//  Created by Alex Shepard on 3/5/18.
//  Copyright © 2018 iNaturalist. All rights reserved.
//

import Foundation
import Gallery
import Photos

extension Gallery.Image {
    
    /// Resolve UIImage synchronously
    ///
    /// - Parameter size: The target size
    /// - Returns: The resolved UIImage, or an error
    public func resolveWithError(completion: @escaping (UIImage?, NSError?) -> Void) {
        let hqOptions = PHImageRequestOptions()
        hqOptions.isNetworkAccessAllowed = true
        hqOptions.deliveryMode = .highQualityFormat
        
        let anyOptions = PHImageRequestOptions()
        anyOptions.isNetworkAccessAllowed = true
        anyOptions.deliveryMode = .fastFormat
        
        let targetSize = CGSize(
            width: asset.pixelWidth,
            height: asset.pixelHeight
        )
        
        PHImageManager.default().requestImage(
            for: asset,
            targetSize: targetSize,
            contentMode: .default,
            options: hqOptions) { (image, info) in
                if let resolved = image {
                    completion(resolved, nil)
                } else {
                    // try downloading the with any
                    PHImageManager.default().requestImage(
                        for: self.asset,
                        targetSize: targetSize,
                        contentMode: .default,
                        options: anyOptions) { (image, info) in
                            if let resolved = image {
                                completion(resolved, nil)
                            } else if let info = info {
                                let error = info[PHImageErrorKey] as? NSError
                                completion(nil, error)
                            } else {
                                completion(nil, nil)
                            }
                    }
                }
        }
    }
}
