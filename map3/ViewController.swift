//
//  ViewController.swift
//  map3
//
//  Created by Canberk Çöl on 25.07.2016.
//  Copyright © 2016 Canberk Çöl. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    var annotation = MKPointAnnotation()
  
    @IBOutlet weak var map: MKMapView!
    let manager = CLLocationManager()
      override func viewDidLoad() {
        super.viewDidLoad()
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        //manager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        manager.startUpdatingLocation()
        manager.distanceFilter = 10000
        
        map.showsUserLocation = false
        
		
        
        // Do any additional setup after loading the view, typically from a nib.
    }
   
    override func  didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
        let region = MKCoordinateRegion(center: center, span: span)
        
        annotation = MKPointAnnotation()
        annotation.title = "-"//city as String
        annotation.subtitle = "-"
        annotation.coordinate = center
        
        map.addAnnotation(annotation)
        map.setRegion(region, animated: true)
    
        
        
        let locValue : CLLocationCoordinate2D = manager.location!.coordinate
        let long = locValue.longitude;
        let lat = locValue.latitude;
        
        let geoCoder = CLGeocoder()
        let location1 = CLLocation(latitude: lat, longitude: long)
        
        geoCoder.reverseGeocodeLocation(location1, completionHandler: { (placemarks, error) -> Void in
            
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            
            // City
            if(placeMark.addressDictionary?["City"] != nil){
            
                if let city = placeMark.addressDictionary?["City"] as? NSString {
                    self.annotation.title = city as String
                    self.annotation.subtitle = "-"
                    print(city)
                    
                    self.getWeatherForLocation(locValue)
                    self.getCityForLocation(locValue)
                }
            }
           })

 }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error.localizedDescription)
    }

    func getWeatherForLocation(location3: CLLocationCoordinate2D){
     
        
        let scriptUrl = "http://api.openweathermap.org/data/2.5/weather?"
        // Add one parameter
        let urlWithParams = scriptUrl + "lat=\(location3.latitude)&lon=\(location3.longitude)&APPID=16dba61002d82976b97779152c8728a7&units=metric"
        // Create NSURL Ibject
        let myUrl = NSURL(string: urlWithParams);
        
        // Creaste URL Request
        let request = NSMutableURLRequest(URL:myUrl!);
        
        // Set request HTTP method to GET. It could be POST as well
        request.HTTPMethod = "GET"
        
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            // Check for error
            if error != nil
            {
                print("error=\(error)")
                return
            }
            
            // Print out response string
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("responseString = \(responseString)")
            
            
            // Convert server json response to NSDictionary
            do {
                if let convertedJsonIntoDict = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary {
                    
                    // Print out dictionary
                    print(convertedJsonIntoDict)
                    
                    // Get value by key
                    let mainDict = convertedJsonIntoDict["main"] as? NSDictionary
                    
                    print("maindict = \(mainDict)")
                    
                    var currentTemp :Float!
                    
                     currentTemp = mainDict?["temp"] as? Float
                    
                    if(currentTemp != nil){
                    self.annotation.subtitle = String(currentTemp) + "°"
                    print("temp = \(currentTemp)")
                    }
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            
        }
        
        task.resume()
        
    }
    
    func getCityForLocation(location4 : CLLocationCoordinate2D){
        let geoCoder = CLGeocoder()
        let location1 = CLLocation(latitude: location4.latitude, longitude: location4.longitude)
        
        geoCoder.reverseGeocodeLocation(location1, completionHandler: { (placemarks, error) -> Void in
            
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            
            // City
            if(placeMark.addressDictionary?["City"] != nil){
                
                if let city = placeMark.addressDictionary?["City"] as? NSString {
                    self.annotation.title = city as String
                    //self.annotation.subtitle = "-"
                    print(city)
                    
                   // [self .getWeatherForLocation(locValue)]
                    
                }
            }
        })

    
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if let touch = touches.first{
        
           
            if (touch.view == self.view) {
               print("view touched")
            }else {
                print("map touched")
            
             annotation.coordinate  = map.convertPoint(touch.locationInView(map), toCoordinateFromView: map)
                self.getWeatherForLocation(annotation.coordinate)
                self.getCityForLocation(annotation.coordinate)
                
                
            }
            //print("\(touch.view)")
                }
 }

}

