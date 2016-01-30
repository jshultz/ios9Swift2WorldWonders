//
//  mapViewController.swift
//  World Wonders
//
//  Created by Jason Shultz on 1/30/16.
//  Copyright © 2016 HashRocket. All rights reserved.
//

import Foundation
import CoreData
import MapKit
import CoreLocation


class mapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    var location:String = ""
    
    var tempLatitude:Double = 0
    var tempLongitude:Double = 0

    var locationManager = CLLocationManager()
    
    @IBOutlet weak var map: MKMapView!
    
    override func viewDidLoad() {
        UINavigationBar.appearance().barTintColor = UIColor.redColor()
    }
    
    override func viewWillAppear(animated: Bool) {
        locationManager.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.startUpdatingLocation()
        
        setupUI()
        
    }
    
    func addMarker(location:CLLocationCoordinate2D){
        
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = location
        
        annotation.title = "This awesome place"
        
        annotation.subtitle = "If you were here you would know it."
        
        map.addAnnotation(annotation)
        
    }
    
    func setupUI() {
        
        self.navigationController?.navigationBar.backgroundColor = UIColor.redColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.blackColor()]
        self.view.backgroundColor = UIColor.orangeColor()
        
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let context: NSManagedObjectContext = appDel.managedObjectContext
        
        let request = NSFetchRequest(entityName: "Locations")
        
        request.predicate = NSPredicate(format: "name = %@", "\(location)")
        
        request.returnsObjectsAsFaults = false
        
        do {
            let results = try context.executeFetchRequest(request)
            if (results.count > 0) {
                for result in results as! [NSManagedObject] {

                    if let locationName = result.valueForKey("name") as? String {
                        self.navigationItem.title = locationName
                    }
                    
                    if let latitude = result.valueForKey("latitude") as? Double {
                        self.tempLatitude = Double(latitude)
                    }
                    
                    if let longitude = result.valueForKey("longitude") as? Double {
                        self.tempLongitude = Double(longitude)
                    }
                    
                    let latitude:CLLocationDegrees = tempLatitude // must use type CLLocationDegrees
                    let longitude:CLLocationDegrees = tempLongitude // must use type CLLocationDegrees
                    
                    let latDelta:CLLocationDegrees = 0.01 // must use type CLLocationDegrees
                    
                    let lonDelta:CLLocationDegrees = 0.01 // must use type CLLocationDegrees
                    
                    let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta) // Combination of two Delta Degrees
                    
                    let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude) // Combination of the latitude and longitude variables
                    
                    let region:MKCoordinateRegion = MKCoordinateRegionMake(location, span) // takes span and location and uses those to set the region.
                    
                    addMarker(location)
        
                    map.setRegion(region, animated: true) // Take all that stuff and make a map!
                    
                }
                
            } else {
                
            }
            
        } catch {
            print("something went terribly wroing")
        }
        
        
    }
    
}