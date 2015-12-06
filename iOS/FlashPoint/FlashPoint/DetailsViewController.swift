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
	public var currentVideo : NSData?
	
	var baseScrollPosition = CGPointMake(0, 0);
	
	var lastLocation : CLLocation?
	@IBOutlet weak var scrollView: UIScrollView!
	@IBOutlet weak var imageToUploadView: UIImageView!
	@IBOutlet weak var descriptionTextField: UITextField!
	//@IBOutlet weak var activityIndicator: UIActivityIndicatorView!

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
		
		// Set up activity indicator
		
	}
	
	public override func viewDidAppear(animated: Bool) {
		if let currentPhoto = self.currentPhoto {
			imageToUploadView.image = currentPhoto
		}
	}

	@IBAction func uploadPicture(sender: AnyObject) {
		func uploadFlashPoint(flashPoint: AnyObject, flashPointType: Int) {
			let flashPointToSend = PFObject(className: "flashPoint")
			flashPointToSend["flashPointDescription"] = descriptionTextField.text
			flashPointToSend["flashPointType"] = flashPointType
			flashPointToSend["flashPointDate"] = NSDate()
			
			if flashPointType == 1 {
				let resizedImage =  ResizeImage(self.imageToUploadView.image!, targetSize: CGSizeMake(150,200));
				flashPointToSend["image"] = PFFile(name: NSUUID().UUIDString + ".jpg", data: UIImageJPEGRepresentation(resizedImage, 0.5)!)
			} else if flashPointType == 2 {
				flashPointToSend["video"] = PFFile(name: NSUUID().UUIDString + ".mp4", data: self.currentVideo!)
			}
			
			if let lastLocation = lastLocation {
				let locationGeoPoint = PFGeoPoint(latitude: lastLocation.coordinate.latitude, longitude: lastLocation.coordinate.longitude)
				flashPointToSend["location"] = locationGeoPoint
			} else {
				print("Image uploaded without location data")
			}
			
			flashPointToSend.saveInBackgroundWithBlock({ (success, error) -> Void in
				if success == true {
					print("FlashPoint uploaded with ID: \(flashPointToSend.objectId)")
				} else {
					print("FlashPoint upload failed")
				}
			})
			
		}
		
		if let photo = self.currentPhoto {
			uploadFlashPoint(photo, flashPointType: 1)
		} else if let video = self.currentVideo {
			uploadFlashPoint(video, flashPointType: 2)
		}
		
		
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
	
	public func textFieldDidEndEditing(DescriptionView: UITextField){
		// Scroll back to base position
		scrollView.setContentOffset(baseScrollPosition, animated: true);
	}
	
	// Location
	public func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		lastLocation = locations.last
	}
	
	public func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
		print("Had an error getting the location")
		self.locationManager?.stopUpdatingLocation()
	}
	
	func ResizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
		let size = image.size
		
		let widthRatio  = targetSize.width  / image.size.width
		let heightRatio = targetSize.height / image.size.height
		
		// Figure out what our orientation is, and use that to form the rectangle
		var newSize: CGSize
		if(widthRatio > heightRatio) {
			newSize = CGSizeMake(size.width * heightRatio, size.height * heightRatio)
		} else {
			newSize = CGSizeMake(size.width * widthRatio,  size.height * widthRatio)
		}
		
		// This is the rect that we've calculated out and this is what is actually used below
		let rect = CGRectMake(0, 0, newSize.width, newSize.height)
		
		// Actually do the resizing to the rect using the ImageContext stuff
		UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
		image.drawInRect(rect)
		let newImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		return newImage
	}
	
	override public func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
}
