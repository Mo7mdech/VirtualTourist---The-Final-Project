//
//  Flickr.swift
//  VirtualTourist
//
//  Created by Mohammed Jarad on 17/07/2019.
//  Copyright © 2019 Jarad. All rights reserved.
//

import Foundation
import MapKit

struct Flickr {
    
    static func getUrl(with cordinates: CLLocationCoordinate2D, numOfPage: Int, completion: @escaping([URL]?, Error?, String?)-> ()){
        let input = [Constants.FlickrKeys.METHOD: Constants.FlickrValues.SEARCH_METHOD,
                     Constants.FlickrKeys.API_KEY: Constants.FlickrValues.API_KEY,
                     Constants.FlickrKeys.BOUNDING_BOX: bboxString(for: cordinates),
                     Constants.FlickrKeys.SAFE_SEARCH: Constants.FlickrValues.USE_SAFE_SEARCH,
                     Constants.FlickrKeys.EXTRAS: Constants.FlickrValues.MEDIUM_URL,
                     Constants.FlickrKeys.FORMAT: Constants.FlickrValues.RESPONSE_FORMATE,
                     Constants.FlickrKeys.NO_JSON_CALLBACK: Constants.FlickrValues.DISABLE_JSON_CALLBACK,
                     Constants.FlickrKeys.PAGE: numOfPage,
                     Constants.FlickrKeys.PERPAGE : 10,] as [String : Any]
        
        let request = URLRequest(url: getURL(from: input))
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard (error == nil) else{
                completion(nil, error, nil)
                return
            }
            
            guard let httpStatusCode = (response as? HTTPURLResponse)?.statusCode else{
                return
            }
            print("httpStatusCode: ",httpStatusCode)
            if httpStatusCode >= 200 && httpStatusCode < 300 {
                print("data -> ",data!)
            }else{
                return
            }
            func sendError(_ error: String) {
                print(error)
            }
            switch (httpStatusCode){
            case 200..<300 :
                break
            case 400 :
                sendError("Bad Request")
            case 401 :
                sendError("Invalid Credentials")
            case 403:
                sendError("Unauthorized")
            case 405:
                sendError("HttpMethod Not Allowed")
            case 410:
                sendError("URL Changed")
            case 500:
                sendError("Server Error")
            default:
                sendError("Unknown error")
            }
            
            guard let data = data else{
                completion(nil, nil, "<<<< No Data Returned >>>>")
                return
            }
            
            guard let output = try? JSONSerialization.jsonObject(with: data, options: []) as! [String: Any] else{
                completion(nil, nil, "<<<< JSON Parsing Failed >>>>")
                return
            }
            
            guard let stat = output["stat"] as? String, stat == "ok" else{
                completion(nil,nil, error?.localizedDescription)
                return
            }
            
            guard let photosResult = output["photos"] as? [String: Any] else{
                completion(nil, nil, error?.localizedDescription)
                return
            }
            
            guard let photosArray = photosResult["photo"] as? [[String: Any]] else{
                completion(nil, nil, error?.localizedDescription)
                return
            }
            
            let PhotosURLs = photosArray.compactMap {photosResult -> URL? in
                guard let url = photosResult["url_m"] as? String else{
                    return nil
                }
                
                return URL(string: url)
            }
            
            completion(PhotosURLs,nil,nil)
            
        }
        task.resume()
    }
    
    static func bboxString(for cordinates: CLLocationCoordinate2D)-> String{
        let lat = cordinates.latitude
        let long = cordinates.longitude
        
        let minLat = max(lat - Constants.Flickr.SEARCH_HEIGHT, Constants.Flickr.SEARCH_LAT.0)
        let maxLat = min(long + Constants.Flickr.SEARCH_HEIGHT, Constants.Flickr.SEARCH_LAT.1)
        let minLong = max(long - Constants.Flickr.SEARCH_WIDTH, Constants.Flickr.SEARCH_LONG.0)
        let maxLong = min(long + Constants.Flickr.SEARCH_WIDTH, Constants.Flickr.SEARCH_LONG.1)
        
        return "\(minLong),\(minLat),\(maxLong),\(maxLat)"
    }
    
    static func getURL(from parameters: [String: Any]) -> URL{
        var components = URLComponents()
        components.scheme = Constants.Flickr.API_SCHEME
        components.host = Constants.Flickr.API_HOST
        components.path = Constants.Flickr.API_PATH
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters{
            let quaryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems?.append(quaryItem)
        }
        return components.url!
    }
    
}
