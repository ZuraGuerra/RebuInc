//
//  ViewController.swift
//  Rebu
//
//  Created by Zura Guerra on 3/2/15.
//  Copyright (c) 2015 Rebu Inc. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBAction func fbConnect(sender: AnyObject) {
        // log in & sign up
        var permissions = ["email", "public_profile", "user_likes"]
        PFFacebookUtils.logInWithPermissions(permissions, {
            (user: PFUser!, error: NSError!) -> Void in
            if user == nil {
                NSLog("Uh oh. The user cancelled the Facebook login.")
                var Register : UINavigationController = self.storyboard!.instantiateViewControllerWithIdentifier("Register") as UINavigationController
                
                self.navigationController!.pushViewController(Register, animated: true)
                
                
            } else if user.isNew {
                NSLog("User signed up and logged in through Facebook!")
                
            } else {
                NSLog("User logged in through Facebook!")
               // self.performSegueWithIdentifier("MapScreen", sender: self)
                
                var MapScreen : UIViewController = self.storyboard!.instantiateViewControllerWithIdentifier("MapScreen") as UIViewController
                
                self.navigationController!.pushViewController(MapScreen, animated: true)
            }
        })
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // save objects to parse
        var object = PFObject(className: "testDataClass")
        object.addObject("iOSBlog", forKey: "websiteUrl")
        object.addObject("Five", forKey: "websiteRating")
        object.save()
        
        
        var timer = NSTimer()
        timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: Selector("carsNearMe"), userInfo: nil, repeats: true)
    }
    
    func carsNearMe() {
        let point = PFGeoPoint(latitude:19.430662, longitude:-99.200996)
        /*
        var query = PFQuery(className:"_User")
        query.whereKey("location", nearGeoPoint:point)
        query.whereKey("driver", equalTo: true)
        query.limit = 10
        
        var placesObjects = query.findObjects()
        println(placesObjects)
        */
        
        var query = PFQuery(className:"_User")
        query.whereKey("location", nearGeoPoint:point)
        query.whereKey("driver", equalTo: true)
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                // The find succeeded.
                println("Successfully retrieved \(objects.count) drivers.")
                // Do something with the found objects
                if let objects = objects as? [PFObject] {
                    for object in objects {
                        
                        var username: AnyObject! = object.objectForKey("username")
                        var location: PFGeoPoint = object.objectForKey("location") as PFGeoPoint
                        
                        println("Driver: \(username)")
                        println("Latitude: \(location.latitude) Longitude: \(location.longitude)")
                    }
                    // println(objects[0].objectForKey("location"))
                }
            } else {
                // Log details of the failure
                println("Error: \(error) \(error.userInfo!)")
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

class mapView: UIViewController, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        NSLog("User's location: %@", manager.location)
        
        var mapView = self.view as GMSMapView
        // mapView.camera = GMSCameraPosition(target: manager.location.coordinate, zoom: 6, bearing: 0, viewingAngle: 0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // For use in background
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if (CLLocationManager.locationServicesEnabled())
        {
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            self.locationManager.requestAlwaysAuthorization()
            self.locationManager.startUpdatingLocation()
        }
        
        var camera = GMSCameraPosition.cameraWithLatitude(29.4284700,
            longitude: -99.1276600, zoom: 6)
        var mapView = GMSMapView.mapWithFrame(CGRectZero, camera: camera)
        mapView.myLocationEnabled = true
        self.view = mapView
        
        var marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(19.4284700, -99.1276600)
        marker.title = "DF"
        marker.snippet = "Mexico"
        marker.map = mapView
        
        
        var marker1 = GMSMarker()
        
        mapView.myLocationEnabled = true
        
        // The myLocation attribute of the mapView may be null
        if let mylocation = mapView.myLocation {
            NSLog("User's location: %@", mylocation)
        } else {
            NSLog("User's location is unknown")
        }
        
        mapView.settings.myLocationButton = true
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    
    
}



