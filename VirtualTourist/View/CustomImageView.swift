//
//  CustomImageView.swift
//  VirtualTourist
//
//  Created by Mohammed Jarad on 20/07/2019.
//  Copyright © 2019 Jarad. All rights reserved.
//

import Foundation
import UIKit

protocol CustomImageViewDelegate {
    func imageDidDownload()
}

let ImagesCache = NSCache<NSString, AnyObject>()

class CustomImageView : UIImageView{
    var imageURL : URL!
    
    func setPhoto(_ newPhoto: Pic){
        if pic != nil{
            return
        }
        pic = newPhoto
    }
    private var pic: Pic! {
        didSet{
            if let image = pic.get(){
                hideActivityIndicator()
                self.image = image
                return
            }
            guard let url = pic.imageURL else{
                return
            }
            loadImage(with: url)
        }
    }
    func loadImage(with url: URL){
        imageURL = url
        image = nil
        showActivityIndicator()
        if let cachedImage = ImagesCache.object(forKey: url.absoluteString as NSString) as? UIImage{
            image = cachedImage
            hideActivityIndicator()
            return
        }
        URLSession.shared.dataTask(with: url){(data, response, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard let DownloadedImage = UIImage(data: data!) else{
                return
            }
            ImagesCache.setObject(DownloadedImage, forKey: url.absoluteString as NSString)
            DispatchQueue.main.async {
                self.image = DownloadedImage
                self.pic.set(image: DownloadedImage)
                try? self.pic.managedObjectContext?.save()
                self.hideActivityIndicator()
            }
        }.resume()
    }
    
    lazy var activityIndicatorView : UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView(style: .whiteLarge)
        self.addSubview(activityIndicatorView)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        activityIndicatorView.color = .black
        activityIndicatorView.hidesWhenStopped = true
        return activityIndicatorView
    }()
    func showActivityIndicator(){
        DispatchQueue.main.async {
            self.activityIndicatorView.startAnimating()
        }
    }
    
    func hideActivityIndicator(){
        DispatchQueue.main.async {
            self.activityIndicatorView.stopAnimating()
        }
    }
}
