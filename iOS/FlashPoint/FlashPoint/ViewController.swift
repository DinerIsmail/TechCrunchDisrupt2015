//
//  ViewController.swift
//  FlashPoint
//
//  Created by Diner Ismail on 05/12/2015.
//  Copyright (c) 2015 FlashPoint. All rights reserved.
//

import UIKit
import Parse
import AVFoundation
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
	//var captureSession : AVCaptureSession?
	//var stillImageOutput : AVCaptureStillImageOutput?
	//var previewLayer : AVCaptureVideoPreviewLayer?
	//var locationManager : CLLocationManager?
	
	var didTakePhoto = Bool()
	var lastLocation : CLLocation?
	
	@IBOutlet weak var cameraView: UIView!
	@IBOutlet weak var previewImageView: UIImageView!

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
	
	override func viewDidAppear(animated: Bool) {
		//previewLayer?.frame = cameraView.bounds
		
		let picker = UIImagePickerController()
		let sourceType = UIImagePickerControllerSourceType.Camera
		
		if UIImagePickerController.isSourceTypeAvailable(sourceType) {
			picker.sourceType = sourceType
			let frontCamera = UIImagePickerControllerCameraDevice.Front
			
			if UIImagePickerController.isCameraDeviceAvailable(frontCamera) {
				picker.cameraDevice = frontCamera
				picker.delegate = self
				self.presentViewController(picker, animated: true, completion: nil)
			}
		}
	}
	
	override func viewWillAppear(animated: Bool) {
		captureSession = AVCaptureSession()
		captureSession?.sessionPreset = AVCaptureSessionPreset1920x1080
		
		let backCamera = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
		
		var error : NSError?
		var input: AVCaptureDeviceInput!
		do {
			input = try AVCaptureDeviceInput(device: backCamera)
		} catch let error1 as NSError {
			error = error1
			input = nil
		}
		
		if (error == nil && captureSession?.canAddInput(input) != nil){
			
			captureSession?.addInput(input)
			
			stillImageOutput = AVCaptureStillImageOutput()
			stillImageOutput?.outputSettings = [AVVideoCodecKey : AVVideoCodecJPEG]
			
			if (captureSession?.canAddOutput(stillImageOutput) != nil){
				captureSession?.addOutput(stillImageOutput)
				
				previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
				previewLayer?.videoGravity = AVLayerVideoGravityResizeAspect
				previewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.Portrait
				cameraView.layer.addSublayer(previewLayer!)
				captureSession?.startRunning()
			}
		}
	}
	
	func didPressTakePhoto() {
		if let videoConnection = stillImageOutput?.connectionWithMediaType(AVMediaTypeVideo){
			videoConnection.videoOrientation = AVCaptureVideoOrientation.Portrait
			stillImageOutput?.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {
				(sampleBuffer, error) in
				
				if sampleBuffer != nil {
					let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
					let dataProvider  = CGDataProviderCreateWithCFData(imageData)
					let cgImageRef = CGImageCreateWithJPEGDataProvider(dataProvider, nil, true, CGColorRenderingIntent.RenderingIntentDefault)
					
					let image = UIImage(CGImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.Right)
					
					self.previewImageView.image = image
					self.previewImageView.hidden = false
				}
			})
		}
	}
	
	func didPressTakeAnother(){
		if didTakePhoto == true {
			previewImageView.hidden = true
			didTakePhoto = false
		}
		else {
			captureSession?.startRunning()
			didTakePhoto = true
			didPressTakePhoto()
		}
	}
	
	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
		didPressTakeAnother();
	}
	
	@IBAction func uploadPicture(sender: AnyObject) {
		if didTakePhoto == true {
			let imageToSend = PFObject(className: "flashPoint")
			imageToSend["image"] = PFFile(name: NSUUID().UUIDString + ".jpg", data: UIImageJPEGRepresentation(self.previewImageView.image!, 0.5)!)
			imageToSend["flashPointDescription"] = "Some description"
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
		}
	}
	
	func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		lastLocation = locations.last
		//self.locationLabel.text = "Lat: \(location!.coordinate.latitude), Long: \(location!.coordinate.longitude)"
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
