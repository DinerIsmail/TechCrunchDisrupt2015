//
//  EventsMapViewController.swift
//  FlashPoint
//
//  Created by Johnnie Walker on 05/12/2015.
//  Copyright © 2015 Robotzi. All rights reserved.
//

import UIKit
import MobileCoreServices

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
		
	}

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Pass the selected object to the new view controller.
		
    }
}
