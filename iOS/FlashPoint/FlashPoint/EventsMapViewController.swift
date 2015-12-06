//
//  EventsMapViewController.swift
//  FlashPoint
//
//  Created by Johnnie Walker on 05/12/2015.
//  Copyright © 2015 Robotzi. All rights reserved.
//

import UIKit

class EventsMapViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	@IBOutlet weak var mapView: UIView!
	
	var imageTaken : UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
				self.presentViewController(picker, animated: true, completion: nil)
			}
		}
	}
	
	func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
		let detailsViewController = self.storyboard?.instantiateViewControllerWithIdentifier("DetailsViewController") as! DetailsViewController
		self.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
		
		let image = info[UIImagePickerControllerOriginalImage] as! UIImage
		self.imageTaken = image
		
		picker.dismissViewControllerAnimated(true, completion: nil)
		detailsViewController.currentPhoto = image
		self.presentViewController(detailsViewController, animated: true, completion: nil)
	}
	
	func imagePickerControllerDidCancel(picker: UIImagePickerController) {
		
	}

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Pass the selected object to the new view controller.
		
		if segue.identifier == "DetailsViewController" {
			let destinationViewController = segue.destinationViewController as! DetailsViewController
			if let imageTaken = self.imageTaken {
				destinationViewController.currentPhoto = imageTaken
			}
		} else {
			
		}
		
    }


}
