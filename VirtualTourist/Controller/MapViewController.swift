//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by Mohammed Jarad on 08/07/2019.
//  Copyright © 2019 Jarad. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate {
    @IBOutlet weak var mapView: MKMapView!
    
    @IBAction func longPressAction(_ sender: UILongPressGestureRecognizer) {
        if sender.state != .began {
            return
        }
        let touchPoint = sender.location(in: mapView)
        let newPin = Pin(context: context)
        newPin.coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        try? context.save()
    }
    
    func updateMapView(){
        guard let pins = fetchResultsController.fetchedObjects else {
            return
        }
        for pin in pins{
            if mapView.annotations.contains(where: {pin.compare(to: $0.coordinate)}){
                continue
            }
            let annotation = MKPointAnnotation()
            annotation.coordinate = pin.coordinate
            mapView.addAnnotation(annotation)
        }
    }
    
    var fetchResultsController: NSFetchedResultsController<Pin>!
    
    var context: NSManagedObjectContext{
        return DataController.shared.viewContext
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchResultsController()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        fetchResultsController = nil
    }
    
    func setupFetchResultsController(){
        let fetchRequest : NSFetchRequest<Pin> = Pin.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchResultsController.delegate = self
        
        do{
            try? fetchResultsController.performFetch()
            updateMapView()
        }
        catch{
            fatalError("error -> \(error.localizedDescription)")
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToPhotoCollection" {
            let collectionVC = segue.destination as! CollectionViewController
            collectionVC.pin = sender as? Pin
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let pin = fetchResultsController.fetchedObjects?.filter{
            $0.compare(to: view.annotation!.coordinate)
        }.first!
        performSegue(withIdentifier: "goToPhotoCollection", sender: pin)
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateMapView()
    }
    
}
