//
//  Constants.swift
//  VirtualTourist
//
//  Created by Mohammed Jarad on 13/07/2019.
//  Copyright © 2019 Jarad. All rights reserved.
//

import Foundation
import MapKit

struct Constants {
    
    struct Flickr {
        static let API_SCHEME = "https"
        static let API_HOST = "api.flickr.com"
        static let API_PATH = "/services/rest"
        static let SEARCH_WIDTH = 1.0
        static let SEARCH_HEIGHT = 1.0
        static let SEARCH_LAT = (-100.0, 100.0)
        static let SEARCH_LONG = (-180.0, 180.0)
    }
    struct FlickrKeys{
        static let METHOD = "method"
        static let API_KEY = "api_key"
        static let EXTRAS = "extras"
        static let FORMAT = "format"
        static let NO_JSON_CALLBACK = "nojsoncallback"
        static let SAFE_SEARCH = "safe_search"
        static let TEXT = "text"
        static let BOUNDING_BOX = "bbox"
        static let PAGE = "page"
        static let PERPAGE = "per_page"
    }
    struct FlickrValues {
        static let SEARCH_METHOD = "flickr.photos.search"
        static let API_KEY = "a5bc5fc347495210ca905e6c414dff03"
        static let RESPONSE_FORMATE = "json"
        static let DISABLE_JSON_CALLBACK = "1"
        static let GALLERY_PHOTOS_METHOD = "flickr.galleries.getphotos"
        static let MEDIUM_URL = "url_m"
        static let USE_SAFE_SEARCH = "1"
    }
}
