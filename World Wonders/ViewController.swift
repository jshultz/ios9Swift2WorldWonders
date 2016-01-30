//
//  ViewController.swift
//  World Wonders
//
//  Created by Jason Shultz on 1/28/16.
//  Copyright © 2016 HashRocket. All rights reserved.
//

import UIKit
import CoreData


class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var array = []
    
    let cellIdentifier = "Cell"
    
    let wikiImageURL:String = ""
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        locationTable.delegate = self
        locationTable.dataSource = self
    }
    
    @IBOutlet weak var locationTable: UITableView!
    
    override func viewWillAppear(animated: Bool) {
        
        // Get Location
        
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let context: NSManagedObjectContext = appDel.managedObjectContext
        
        let request = NSFetchRequest(entityName: "Locations")
        
        request.returnsObjectsAsFaults = false
        
        do {
            let results = try context.executeFetchRequest(request)
            if (results.count <= 0) {
                fetchJSON()
                setupUI()
                self.locationTable.reloadData()
            } else {
                setupUI()
            }
            
        } catch {
            print("something went terribly wroing")
        }
    }
    
    func fetchJSON() {
        print("in fetchJSON")
        
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let context: NSManagedObjectContext = appDel.managedObjectContext
        
        let url:NSURL = NSURL(string: "https://jsonblob.com/api/56aa8522e4b01190df4c13a2")!
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) -> Void in
            if let urlContent = data {
                do {
                    let jsonResult = try NSJSONSerialization.JSONObjectWithData(urlContent, options: NSJSONReadingOptions.MutableContainers)
                    
                    for location in jsonResult as! [Dictionary<String, AnyObject>] {

//                        print("location: ", location)
                        let newLocation = NSEntityDescription.insertNewObjectForEntityForName("Locations", inManagedObjectContext: context)
                        
//                        var theFileName:String = NSURL(fileURLWithPath: String(location["image"]!)).lastPathComponent!
                        
//                        var theFileName:String = String(location["image"]!.lastPathComponent)
                        
                        newLocation.setValue(location["image"], forKey: "image")
                        newLocation.setValue(location["latitude"], forKey: "latitude")
                        newLocation.setValue(location["location"], forKey: "location")
                        newLocation.setValue(location["longitude"], forKey: "longitude")
                        newLocation.setValue(location["name"], forKey: "name")
                        newLocation.setValue(location["region"], forKey: "region")
                        newLocation.setValue(location["wikipedia"], forKey: "wikipedia")
                        newLocation.setValue(location["year_built"], forKey: "year_built")
                                                
                        do {
                            try context.save()
                            
                            self.findImage(String(location["image"]!))
                            print("i saved it")
                        } catch {
                            print("There was a problem")
                        }
                        
                    }
                    
                } catch {
                    print("JSON serialization failed")
                }
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                print("in this")
                self.setupUI()
            })
        }
        task.resume()
        
        
        
    }
    
    func setupUI() {
//        self.edgesForExtendedLayout = UIRectEdge.None
        self.navigationController?.navigationBar.backgroundColor = UIColor.redColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.blackColor()]
        
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

        let context: NSManagedObjectContext = appDel.managedObjectContext
        
        let request = NSFetchRequest(entityName: "Locations")
        
        self.locationTable.backgroundColor = UIColor.orangeColor()
        
        request.returnsObjectsAsFaults = false
        
        do {
            let results = try context.executeFetchRequest(request)
            if (results.count > 0) {
                
                self.array = results
                                
            }
            
        } catch {
            print("something went terribly wroing")
        }
    }
    
    // MARK:  UITextFieldDelegate Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as UITableViewCell
        
        cell.backgroundColor = colorForIndex(indexPath.row)
        
        let object = array[indexPath.row]
        
        let subTitle = cell.viewWithTag(20) as! UILabel
        
        let thumbnail = cell.viewWithTag(30) as? UIImageView
        
        if let locationName = object.valueForKey("name") as? String {
            cell.textLabel?.text = locationName
        }
        
        if let locationLocation = object.valueForKey("location") as? String {
            subTitle.text = locationLocation
        }
        
        let imageView = UIImageView(frame: CGRectMake(10, 10, cell.frame.width - 10, cell.frame.height - 10))
        
        imageView.contentMode = .ScaleAspectFit
        
        if let img_url = object.valueForKey("image") as? String {
            
            if let checkedUrl = NSURL(string: "\(img_url)") {
                thumbnail!.contentMode = .ScaleAspectFit
                
                getDataFromUrl(checkedUrl) { (data, response, error)  in
                    
                    dispatch_async(dispatch_get_main_queue()) { () -> Void in
                        guard let data = data where error == nil else { return }
                        thumbnail!.image = UIImage(data: data)
                    }
                }
            }
            
        }
        
        return cell
    }
    
    // MARK:  UITableViewDelegate Methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
    
    func colorForIndex(index: Int) -> UIColor {
        let itemCount = array.count - 1
        let color = (CGFloat(index) / CGFloat(itemCount)) * 0.6
        return UIColor(red: 1.0, green: color, blue: 0.0, alpha: 1.0)
    }
    
    func getDataFromUrl(url:NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            completion(data: data, response: response, error: error)
            }.resume()
    }
    
    func findImage(url:String) {
        
        var wasSuccessful = false
        
        let fetchURL:NSURL = NSURL(string: String(url))!
        
        if fetchURL != "" {
            let task = NSURLSession.sharedSession().dataTaskWithURL(fetchURL) { (data, response, error) -> Void in
                if let urlContent = data {
                    
                    let webContent = NSString(data: urlContent, encoding: NSUTF8StringEncoding)
                    
                    let websiteArray = webContent?.componentsSeparatedByString("<div class=\"mw-filepage-resolutioninfo\">Size of this preview: <a href=\"")
                    if websiteArray!.count > 1 {
                        
                        let fileArray = websiteArray![1].componentsSeparatedByString("\" class=\"")
                        
                        if fileArray.count > 0 {
                            
                            wasSuccessful = true
                            
                            let wikiImageURL = fileArray[0]
                            print("wikiImageURL: ", wikiImageURL)
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in

                                let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                                
                                let context: NSManagedObjectContext = appDel.managedObjectContext
                                
                                let request = NSFetchRequest(entityName: "Locations")
                                
                                request.predicate = NSPredicate(format: "image = %@", url)
                                
                                request.returnsObjectsAsFaults = false
                                
                                do {
                                    let results = try context.executeFetchRequest(request)
                                    if (results.count > 0) {
                                        print("Found: ", wikiImageURL)
                                        for result in results as! [NSManagedObject] {
                                            result.setValue("https:" + wikiImageURL, forKey: "image")
                                            print("result: ", result)
                                            do {
                                                try context.save()
                                                print("i saved it")
                                            } catch {
                                                print("There was a problem")
                                            }

                                        }

                                    } else {

                                    }
                                    
                                } catch {
                                    print("something went terribly wroing")
                                }
                                self.locationTable.reloadData()

                                
                            })
                        }
                        
                        
                        
                    } else {
                        print("could not find image")
                    }
                    
                } else {
                    print("could not find image")
                }
            }
            task.resume()
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "showWonder" {
            let destinationController = segue.destinationViewController as! locationDetailController
            let indexPath = locationTable.indexPathForSelectedRow!
            let location = array[indexPath.row]
            destinationController.location = location.name
            let destinationTitle = location.name
            print("destinationTitle: ", destinationTitle)
            destinationController.title = destinationTitle
            
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

