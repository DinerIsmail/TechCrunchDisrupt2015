//
//  PostTextViewController.swift
//  FlashPoint
//
//  Created by Johnnie Walker on 06/12/2015.
//  Copyright © 2015 Robotzi. All rights reserved.
//

import UIKit
import Parse
import CoreLocation

class PostTextViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate {
	@IBOutlet weak var textField: UITextField!
	
	var locationManager : CLLocationManager?
	var lastLocation : CLLocation?
	
    override func viewDidLoad() {
        super.viewDidLoad()

		self.locationManager = CLLocationManager()
		self.locationManager?.requestWhenInUseAuthorization()
		
		if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.Denied {
			NSLog("Location permission was denied")
		}
		
		self.locationManager?.delegate = self
		self.locationManager?.desiredAccuracy = kCLLocationAccuracyBest
		self.locationManager?.startUpdatingLocation()
    }
	
	@IBAction func postTextButton(sender: AnyObject) {
		let flashPointToSend = PFObject(className: "flashPoint")
		flashPointToSend["flashPointDescription"] = textField.text
		flashPointToSend["flashPointType"] = 0
		flashPointToSend["flashPointDate"] = NSDate()
		
		if let lastLocation = lastLocation {
			let locationGeoPoint = PFGeoPoint(latitude: lastLocation.coordinate.latitude, longitude: lastLocation.coordinate.longitude)
			flashPointToSend["location"] = locationGeoPoint
		} else {
			print("Image uploaded without location data")
		}
		
		flashPointToSend.saveInBackgroundWithBlock({ (success, error) -> Void in
			if success == true {
				print("FlashPoint uploaded with ID: \(flashPointToSend.objectId)")
				self.dismissViewControllerAnimated(true, completion: nil)
			} else {
				print("FlashPoint upload failed")
			}
		})
	}
	
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return false
	}
	
	// Location
	func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		lastLocation = locations.last
	}
	
	func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
		print("Had an error getting the location")
		self.locationManager?.stopUpdatingLocation()
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
