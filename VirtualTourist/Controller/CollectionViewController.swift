//
//  CollectionViewController.swift
//  VirtualTourist
//
//  Created by Mohammed Jarad on 08/07/2019.
//  Copyright © 2019 Jarad. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import MapKit

class CollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var barButton: UIBarButtonItem!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    
    var fetchResultsController: NSFetchedResultsController<Pic>!
    
    var context: NSManagedObjectContext{
        return DataController.shared.viewContext
    }
    
    var havePhotos: Bool{
        return(fetchResultsController.fetchedObjects?.count ?? 0) != 0
    }
    
    var isDeletingAll = false
    var pin: Pin!
    var pageNumber = 1
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResultsController.fetchedObjects?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath) as! CollectionCell
        let pic = fetchResultsController.object(at: indexPath)
        cell.collectionImage.setPhoto(pic)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let pic = fetchResultsController.object(at: indexPath)
        print("indexPath : ",indexPath)
        context.delete(pic)
        try? context.save()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width-20) / 3
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    @IBAction func buttonAction(_ sender: Any) {
        updateUI(processing: true)
        if havePhotos{
            isDeletingAll = true
            for pic in fetchResultsController.fetchedObjects!{
                context.delete(pic)
            }
            try? context.save()
            isDeletingAll = false
        }
        Flickr.getUrl(with: pin.coordinate, numOfPage: pageNumber+1) { (url, error, errorMessage) in
            DispatchQueue.main.async {
                self.updateUI(processing: false)
                guard (error == nil) && (errorMessage == nil) else{
                    self.alert(title: "There is an Error", message: error?.localizedDescription ?? errorMessage)
                    return
                }
                guard let url = url, !url.isEmpty else{
                    self.label.isHidden = false
                    return
                }
                for _url in url{
                    let pic = Pic(context: self.context)
                    pic.imageURL = _url
                    pic.pin = self.pin
                }
                try? self.context.save()
            }
        }
        pageNumber += 1
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        fetchResultsController = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchResultsController()
        setupMapView()
        label.isHidden = true
    }
    
    private func setupMapView() {
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: pin.coordinate, span: span)
        mapView.setRegion(region, animated: false)
        
        let currentMapRect = mapView.visibleMapRect
        
        var topPadding: CGFloat = 0
        if let safeAreaTopInset = UIApplication.shared.keyWindow?.safeAreaInsets.top,
            let navigationBarHeight = navigationController?.navigationBar.frame.height {
            topPadding = safeAreaTopInset + navigationBarHeight
        }
        
        let padding = UIEdgeInsets(top: topPadding, left: 0.0, bottom: 0.0, right: 0.0)
        mapView.setVisibleMapRect(currentMapRect, edgePadding: padding, animated: true)
        mapView.addAnnotation(pin)
        
        mapView.isUserInteractionEnabled = false
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        if let indexPath = indexPath, type == .delete && !isDeletingAll{
            collectionView.deleteItems(at: [indexPath])
            return
        }

        if let indexPath = indexPath, type == .insert{
            collectionView.insertItems(at: [indexPath])
            return
        }

        if let newIndexPath = newIndexPath, let oldIndexPath = indexPath, type == .move{
            collectionView.moveItem(at: oldIndexPath, to: newIndexPath)
            print("oldIndexPath : ",oldIndexPath)
            print("newIndexPath : ",newIndexPath)
            return
        }

        if type != .update {
            collectionView.reloadData()
        }
    }
    
    func setupFetchResultsController(){
        let fetchRequest: NSFetchRequest<Pic> = Pic.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchResultsController.delegate = self
        
        do{
            try? fetchResultsController.performFetch()
            if havePhotos{
                updateUI(processing: false)
            }
            else{
                buttonAction(self)
            }
        }catch{
            fatalError("error -> \(error.localizedDescription)")
        }
    }
    
    func updateUI(processing: Bool){
        collectionView.isUserInteractionEnabled = !processing
        if processing{
            barButton.title = ""
            activityIndicator.startAnimating()
        }else{
            activityIndicator.stopAnimating()
            barButton.title = "New Collection"
        }
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        collectionView.reloadData()
    }
    
}
