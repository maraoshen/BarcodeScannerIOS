//
//  cameraViewController.swift
//  view trial2
//
//  Created by mara shen on 2/7/15.
//  Copyright (c) 2015 mara shen. All rights reserved.
//

import UIKit
import AVFoundation

//global variable para sa isang class

class cameraViewController: UIViewController, /* For capturing barcodes */AVCaptureMetadataOutputObjectsDelegate {

    @IBOutlet weak var cameraView: UIView!  //view for the camera
    let captureSession = AVCaptureSession()
    var previewLayer : AVCaptureVideoPreviewLayer?
    
    var barcodeString:String = ""
    
    // If we find a device we'll store it here for later use
    var captureDevice : AVCaptureDevice?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        
        let devices = AVCaptureDevice.devices()
        
        // Loop through all the capture devices on this phone
        for device in devices {
            // Make sure this particular device supports video
            if (device.hasMediaType(AVMediaTypeVideo)) {
                // Finally check the position and confirm we've got the back camera
                if(device.position == AVCaptureDevicePosition.Back) {
                    captureDevice = device as? AVCaptureDevice
                    if captureDevice != nil {
                        println("Capture device found")
                        beginSession()
                    }
                }
            }
        }
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
  
    // MARK: actions
    
    @IBAction func cancelCameraButton(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func enterSKUButton(sender: UIBarButtonItem) {
    
        let alertEnterSKUNumber = UIAlertController(title: "Enter SKU Number", message: "Enter Product's SKU Number", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
    }

    // MARK: Functions
    
    func beginSession() {
        
        var err : NSError? = nil
        captureSession.addInput(AVCaptureDeviceInput(device: captureDevice, error: &err))
        
        if err != nil {
            println("error: \(err?.localizedDescription)")
        }
        
        addOutputForBarcodeMetadata()
        //for the camera to fill the entire cameraView
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        let bounds = cameraView.layer.bounds
        previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        previewLayer?.bounds = bounds
        previewLayer?.position = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds))
        cameraView.layer.addSublayer(previewLayer)
        
        //get the initial orientation
        let previewLayerConnection = previewLayer?.connection
        var orientation = UIApplication.sharedApplication().statusBarOrientation
        
        //change camera orientation based on app orientation
        if orientation == UIInterfaceOrientation.Portrait{
            previewLayerConnection?.videoOrientation = AVCaptureVideoOrientation.Portrait
        }else if orientation == UIInterfaceOrientation.LandscapeLeft{
            previewLayerConnection?.videoOrientation = AVCaptureVideoOrientation.LandscapeLeft
        }else if orientation == UIInterfaceOrientation.LandscapeRight{
            previewLayerConnection?.videoOrientation = AVCaptureVideoOrientation.LandscapeRight
        }else if orientation == UIInterfaceOrientation.PortraitUpsideDown{
            previewLayerConnection?.videoOrientation = AVCaptureVideoOrientation.PortraitUpsideDown
        }

        captureSession.startRunning()
        
        
        /*
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.view.layer.addSublayer(previewLayer)
        previewLayer?.frame = self.view.layer.frame
        captureSession.startRunning()
        */
    }
    
    // MARK: ViewControllerDelegate
    
    //detect the orientation change
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        let previewLayerConnection = previewLayer?.connection
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        coordinator.animateAlongsideTransition({ (UIViewControllerTransitionCoordinatorContext) -> Void in
            let orient = UIApplication.sharedApplication().statusBarOrientation
            
            switch orient {
            case .Portrait:
                println("Portrait")
                previewLayerConnection?.videoOrientation = AVCaptureVideoOrientation.Portrait
                // Do something
            case .LandscapeLeft:
                println("LF")
                previewLayerConnection?.videoOrientation = AVCaptureVideoOrientation.LandscapeLeft
            case .LandscapeRight:
                println("LR")
                previewLayerConnection?.videoOrientation = AVCaptureVideoOrientation.LandscapeRight
            case .PortraitUpsideDown:
                println("PUD")
                previewLayerConnection?.videoOrientation = AVCaptureVideoOrientation.PortraitUpsideDown
            default:
                println("default")
                // Do something else
            }
            
            }, completion: { (UIViewControllerTransitionCoordinatorContext) -> Void in
                println("rotation completed")
        })
    }
    
    // Capture metadata for barcodes
    var metadataOutput = AVCaptureMetadataOutput()
    func addOutputForBarcodeMetadata() {
        metadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        captureSession.addOutput(metadataOutput)
        
        // This line is required, as little sense at that makes
        metadataOutput.metadataObjectTypes = metadataOutput.availableMetadataObjectTypes
    }
    
    // MARK: AVCaptureMetadataOutputObjectsDelegate
    var canCaptureBarcode = true
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        
        if !canCaptureBarcode {
            return
        }
        
        // Types of barcodes AVKit will be able to find
        let barcodeTypes = [AVMetadataObjectTypeUPCECode, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode39Mod43Code,
            AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeCode128Code,
            AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeQRCode, AVMetadataObjectTypeAztecCode] as [String]
        
        // Loop through the returned metadata objects (might include a barcode)
        for metadata in metadataObjects {
            
            // Use Swift's find() function to get the index of the metadata type, to see if it's in the list of barcode types
            // e.g. is the metadata object a barcode
            if find(barcodeTypes, String(metadata.type)) != nil {
                // If it is, print out the type so we can see what it is
                
                println("Barcode type is \(String(metadata.type))")
                
                // Get the barcode object in machine readable format
                if let barcode = self.previewLayer?.transformedMetadataObjectForMetadataObject(metadata as! AVMetadataObject) as? AVMetadataMachineReadableCodeObject {
                    
                    // Get the barcode string
                    barcodeString = barcode.stringValue
                    
                    //go to next scene if barcode detected
                    performSegueWithIdentifier("itemSegue", sender: self)
                    
                    //stop camera session
                    captureSession.stopRunning()
                    self.previewLayer?.removeFromSuperlayer()
                    self.previewLayer = nil
                    //self.captureSession = nil
                    
                    return
                    
                }
            }
        }
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "itemSegue"{
            if let destinationVC = segue.destinationViewController as? itemViewController{
                destinationVC.barcodeStr = barcodeString
            }
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
 

}
