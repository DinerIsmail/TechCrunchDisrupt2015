//
//  EventsMapViewController.swift
//  FlashPoint
//
//  Created by Johnnie Walker on 05/12/2015.
//  Copyright © 2015 Robotzi. All rights reserved.
//

import UIKit
import MobileCoreServices
import MapKit
import Parse

class EventsMapViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MKMapViewDelegate {
	@IBOutlet weak var mapView: UIView!
	@IBOutlet weak var mkMapView: MKMapView!
	
	var imageTaken : UIImage?
	
	let regionRadius: CLLocationDistance = 500

    override func viewDidLoad() {
        super.viewDidLoad()
		
		mkMapView.delegate = self;

		let initialLocation = CLLocation(latitude: 51.54383596999999, longitude: -0.01451434999999999)
		centerMapOnLocation(initialLocation)
    }
	
	func centerMapOnLocation(location: CLLocation) {
		let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
		mkMapView.setRegion(coordinateRegion, animated: true)
		
		getEventsForMapView()
	}
    
	@IBAction func useCamera(sender: AnyObject) {
		let picker = UIImagePickerController()
		let sourceType = UIImagePickerControllerSourceType.Camera
		
		if UIImagePickerController.isSourceTypeAvailable(sourceType) {
			picker.sourceType = sourceType
			let rearCamera = UIImagePickerControllerCameraDevice.Rear
			
			if UIImagePickerController.isCameraDeviceAvailable(rearCamera) {
				picker.cameraDevice = rearCamera
				picker.delegate = self
				picker.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
				picker.videoQuality = UIImagePickerControllerQualityType.TypeMedium
				
				self.presentViewController(picker, animated: true, completion: nil)
			}
		}
	}
	
	func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
		let detailsViewController = self.storyboard?.instantiateViewControllerWithIdentifier("DetailsViewController") as! DetailsViewController
		self.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext

		let mediaType = info[UIImagePickerControllerMediaType] as! NSString
		picker.dismissViewControllerAnimated(true) { () -> Void in
			if mediaType == kUTTypeImage {
				detailsViewController.currentPhoto = info[UIImagePickerControllerOriginalImage] as? UIImage
			} else if mediaType == kUTTypeMovie {
				let path = (info[UIImagePickerControllerMediaURL] as! NSURL).path
				if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(path!) {
					//TODO: Add callback for showing confirmation that video was saved
					UISaveVideoAtPathToSavedPhotosAlbum(path!, self, nil, nil)
					print("Video was probably saved succesfully")
					detailsViewController.currentVideo = NSData(contentsOfFile: path!)
				}
			}
		}
		
		self.presentViewController(detailsViewController, animated: true, completion: nil)
	}
	
	func video(video: NSString, didFinishSavingWithError error: NSError?, contextInfo info: AnyObject) {
		var title = "Success"
		var message = "Video was saved"
		
		if let saveError = error {
			title = "Error"
			message = "Video failed to save"
		}
		
		let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
		alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
		presentViewController(alert, animated: true, completion: nil)
	}
	
	func imagePickerControllerDidCancel(picker: UIImagePickerController) {
		picker.dismissViewControllerAnimated(true, completion: nil)
	}
	
	// Map View
	
	func getEventsForMapView() {
		var getEventsQuery = PFQuery(className: "event")
		getEventsQuery.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
			if let objects = objects {
				for object in objects {
					let eventAnnotation = EventAnnotation(title: (object["title"] as? String)!, eventDate: object["eventDate"] as! NSDate, location: CLLocationCoordinate2D(latitude: object["location"].latitude, longitude: object["location"].longitude))
					self.mkMapView.addAnnotation(eventAnnotation)
				}
			}
		}
	}
	
	func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
		if let annotation = annotation as? EventAnnotation {
			let identifier = "pin"
			var view: MKPinAnnotationView
			if let dequeuedView = mkMapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
				as? MKPinAnnotationView {
					dequeuedView.annotation = annotation
					view = dequeuedView
			} else {
				view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
				view.canShowCallout = true
				view.calloutOffset = CGPoint(x: -5, y: 5)
				view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView
				
			}
			return view
		}
		return nil
	}
	
	func mapItem() -> MKMapItem {
	  //let addressDictionary = [String(kABPersonAddressStreetKey): subtitle]
	  //let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDictionary)
			
	  let mapItem = MKMapItem()
	  mapItem.name = title
			
	  return mapItem
	}
	
	func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
		let location = view.annotation as! EventAnnotation
		//let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
		//location.mapItem().openInMapsWithLaunchOptions(launchOptions)
		
//		var center: CGPoint = CGPointMake()
//		UIView.beginAnimations(nil, context: nil)
//		UIView.setAnimationDuration(1.0)
//		UIView.commitAnimations()
	}

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Pass the selected object to the new view controller.
    }
}

class EventAnnotation: NSObject, MKAnnotation {
	let title: String?
	let eventDate: NSDate
	let coordinate: CLLocationCoordinate2D
	//let locationName: String?
	
	init(title: String, eventDate: NSDate, location: CLLocationCoordinate2D) {
		self.title = title
		self.eventDate = eventDate
		self.coordinate = location
		//self.locationName = locationName
	
		super.init()
	}
	
//	var subtitle: String? {
//		return locationName!
//	}
}
