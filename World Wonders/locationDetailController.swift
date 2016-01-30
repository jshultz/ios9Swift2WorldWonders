//
//  locationDetailController.swift
//  World Wonders
//
//  Created by Jason Shultz on 1/29/16.
//  Copyright © 2016 HashRocket. All rights reserved.
//

import UIKit
import CoreData


class locationDetailController: UIViewController {

    var location:String = ""
    
    @IBOutlet weak var locationLocation: UILabel!
    
    @IBOutlet weak var locationRegion: UILabel!
    
    @IBOutlet weak var locationYearBuilt: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    
    
    
    func getDataFromUrl(url:NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            completion(data: data, response: response, error: error)
            }.resume()
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
                    print("result: ", result)
                    
                    if let locationName = result.valueForKey("name") as? String {
                        self.navigationItem.title = locationName
                    }
                    
                    if let img_url = result.valueForKey("image") as? String {
                        
                        if let checkedUrl = NSURL(string: "\(img_url)") {
                            
                            imageView!.contentMode = .ScaleAspectFit
                            imageView!.clipsToBounds = true
                            
                            getDataFromUrl(checkedUrl) { (data, response, error)  in
                                
                                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                                    guard let data = data where error == nil else { return }
                                    //                                    self.view.backgroundColor = UIColor(patternImage: UIImage(data: data)!)
                                    self.imageView!.image = UIImage(data: data)
                                }
                            }
                        }
                        
                    }
                    
                    if let locationCountry = result.valueForKey("location") as? String {
                        self.locationLocation.text = "Country: \(locationCountry)"
                    }
                    
                    if let locationRegion = result.valueForKey("region") as? String {
                        self.locationRegion.text = "Region: \(locationRegion)"
                    }
                    
                    if let locationYear = result.valueForKey("year_built") as? String {
                        self.locationYearBuilt.text = "Year Built: \(locationYear)"
                    }
                    
                }
                
            } else {
                
            }
            
        } catch {
            print("something went terribly wroing")
        }
    }
    
    override func viewDidLoad() {
        UINavigationBar.appearance().barTintColor = UIColor.redColor()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        setupUI()
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "showMap" {
            
            let destinationController = segue.destinationViewController as! mapViewController
            destinationController.location = location
            let destinationTitle = location
            print("destinationTitle: ", destinationTitle)
            destinationController.title = destinationTitle
        }
    }
    
}
