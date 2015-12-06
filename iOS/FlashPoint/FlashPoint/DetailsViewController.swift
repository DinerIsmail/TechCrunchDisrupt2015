//
//  ViewController.swift
//  FlashPoint
//
//  Created by Diner Ismail on 05/12/2015.
//  Copyright (c) 2015 FlashPoint. All rights reserved.
//

import UIKit
import Parse
import CoreLocation

public class DetailsViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate {
	var locationManager : CLLocationManager?
	public var currentPhoto : UIImage?
	
	var baseScrollPosition = CGPointMake(0, 0);
	
	var lastLocation : CLLocation?
	@IBOutlet weak var scrollView: UIScrollView!
	@IBOutlet weak var imageToUploadView: UIImageView!
	@IBOutlet weak var descriptionTextField: UITextField!

    override public func viewDidLoad() {
        super.viewDidLoad()
		
		// Dealing with the Scroll View
		scrollView.contentInset = UIEdgeInsetsMake(0, 0, 300, 0);
		scrollView.contentOffset = CGPointMake(0, 0);
		
		self.descriptionTextField.delegate = self
		
		self.locationManager = CLLocationManager()
		self.locationManager?.requestWhenInUseAuthorization()
		
		if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.Denied {
			NSLog("Location permission was denied")
		}
		
		self.locationManager?.delegate = self
		self.locationManager?.desiredAccuracy = kCLLocationAccuracyBest
		self.locationManager?.startUpdatingLocation()
	}
	
	public override func viewDidAppear(animated: Bool) {
		if let currentPhoto = self.currentPhoto {
			imageToUploadView.image = currentPhoto
		}
	}

	@IBAction func uploadPicture(sender: AnyObject) {
		//if didTakePhoto == true {
			let imageToSend = PFObject(className: "flashPoint")
			imageToSend["image"] = PFFile(name: NSUUID().UUIDString + ".jpg", data: UIImageJPEGRepresentation(self.imageToUploadView.image!, 0.5)!)
			imageToSend["flashPointDescription"] = descriptionTextField.text
			imageToSend["flashPointType"] = 1
			imageToSend["flashPointDate"] = NSDate()
			
			if let lastLocation = lastLocation {
				let locationGeoPoint = PFGeoPoint(latitude: lastLocation.coordinate.latitude, longitude: lastLocation.coordinate.longitude)
				imageToSend["location"] = locationGeoPoint
			} else {
				print("Image uploaded without location data")
			}

			imageToSend.saveInBackgroundWithBlock({ (success, error) -> Void in
				if success == true {
					print("Image uploaded with ID: \(imageToSend.objectId)")
				} else {
					print("Image upload failed")
				}
			})
		//}
	}
	
	// Keyboard
	public func textFieldDidBeginEditing(textField: UITextField) {
		self.descriptionTextField.text = "";

		// Scroll to have the view in focus
		var gotoPosition = CGPointMake(0, 0);
		gotoPosition.y = self.descriptionTextField.frame.minY;
		gotoPosition.y -= 100;

		scrollView.setContentOffset(gotoPosition, animated: true)
	}
	
	public func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
		if string == "\n" {
			descriptionTextField.resignFirstResponder()
			return false
		}

		return true;
	}
	
	public func textFieldShouldReturn(textField: UITextField) -> Bool {
		descriptionTextField.resignFirstResponder()
		return false
	}
	
	// Location
	public func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		lastLocation = locations.last
	}
	
	public func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
		print("Had an error getting the location")
		self.locationManager?.stopUpdatingLocation()
	}
	
	override public func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
}
