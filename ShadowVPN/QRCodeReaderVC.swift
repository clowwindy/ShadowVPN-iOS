//
//  QRCodeReaderVC.swift
//  ShadowVPN
//
//  Created by Joe on 16/2/10.
//  Copyright © 2016年 clowwindy. All rights reserved.
//

import UIKit
import AVFoundation
import Photos


let SCREEN_HEIGHT = UIScreen.mainScreen().bounds.height
let SCREEN_WIDTH = UIScreen.mainScreen().bounds.width


class QRCodeReaderVC: UIViewController, AVCaptureMetadataOutputObjectsDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var captureSession: AVCaptureSession?
    var captureVideoPreviewLayer: AVCaptureVideoPreviewLayer?
    var focusFrame: UIView?
    var delegate: QRCodeWriteBackDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Albums", style: UIBarButtonItemStyle.Plain, target: self, action: "selectFromAlbum:")

        self.setupCapture()
        self.configureVideoPreviewLayer()
        self.initializeFocusFrame()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func selectFromAlbum(sender: UIBarButtonItem) {
        if captureSession != nil {
            captureSession?.stopRunning()
        }
        
        let status = PHPhotoLibrary.authorizationStatus()
        
        switch status {
        case .Denied, .Restricted:
            let alert = UIAlertController(title: "No Permission", message: "You should approve ShadowVPN to access your photos", preferredStyle: UIAlertControllerStyle.Alert)
            
            let settingAction = UIAlertAction(title: "Setup", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    let settingURL = NSURL(string: UIApplicationOpenSettingsURLString)
                    UIApplication.sharedApplication().openURL(settingURL!)
                })
            })
            alert.addAction(settingAction)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
            alert.addAction(cancelAction)
            self.presentViewController(alert, animated: true, completion: nil)
        default:
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true) { () -> Void in
            if self.captureSession != nil {
                self.captureSession?.startRunning()
            }
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        let image = CIImage(image: info[UIImagePickerControllerOriginalImage] as! UIImage)
        
        let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: nil)
        let features = detector.featuresInImage(image!)
        if features.count > 0 {
            let feature = features[0] as! CIQRCodeFeature
            self.parseQRCodeContext(context: feature.messageString)
        } else {
            if captureSession != nil {
                captureSession?.startRunning()
            }
        }
    }
    
    func setupCapture() {
        self.view.backgroundColor = UIColor.blackColor()
        let status = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
        switch status {
        case .Denied, .Restricted:
            let alert = UIAlertController(title: "No Permission", message: "You should approve ShadowVPN to access your video capture", preferredStyle: UIAlertControllerStyle.Alert)
            
            let settingAction = UIAlertAction(title: "Setup", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction) -> Void in
                let settingURL = NSURL(string: UIApplicationOpenSettingsURLString)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    UIApplication.sharedApplication().openURL(settingURL!)
                })
            })
            alert.addAction(settingAction)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
            alert.addAction(cancelAction)
            self.presentViewController(alert, animated: true, completion: nil)
        default:
            self.configureInputDevice()
        }
    }
    
    func configureInputDevice() {
        let captureInput: AnyObject!
        let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        do {
            captureInput = try AVCaptureDeviceInput(device: captureDevice)
        } catch {
            NSLog("\(error)")
            captureInput = nil
        }
        
        captureSession = AVCaptureSession()
        captureSession!.addInput(captureInput as! AVCaptureInput)
        
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession?.addOutput(captureMetadataOutput)
        
        self.setupScanRect(captureMetaDataOutput: captureMetadataOutput)
        captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
    }
    
    func setupScanRect(captureMetaDataOutput output: AVCaptureMetadataOutput) {
        let scanRect = CGRectMake((SCREEN_WIDTH - 300) / 2, (SCREEN_HEIGHT - 300) / 2, 300, 300)
        let y = scanRect.origin.x / SCREEN_WIDTH
        let x = scanRect.origin.y / SCREEN_HEIGHT
        let height = scanRect.width / SCREEN_WIDTH
        let width = scanRect.height / SCREEN_HEIGHT
        output.rectOfInterest = CGRectMake(x, y, width, height)
    }
    
    func configureVideoPreviewLayer() {
        captureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        captureVideoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        captureVideoPreviewLayer!.frame = self.view.bounds
        self.view.layer.addSublayer(captureVideoPreviewLayer!)
        
        let scanArea = UIView()
        scanArea.frame = CGRectMake((SCREEN_WIDTH - 300) / 2, (SCREEN_HEIGHT - 300) / 2, 300, 300)
        scanArea.layer.borderColor = UIColor.whiteColor().CGColor
        scanArea.layer.borderWidth = 2.0
        self.view.addSubview(scanArea)

        captureSession?.startRunning()
    }
    
    func initializeFocusFrame() {
        focusFrame = UIView()
        focusFrame?.layer.borderColor = UIColor.greenColor().CGColor
        focusFrame?.layer.borderWidth = 5
        self.view.addSubview(focusFrame!)
        self.view.bringSubviewToFront(focusFrame!)
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        if metadataObjects == nil || metadataObjects.count == 0 {
            focusFrame?.frame = CGRectZero
            return
        }
        let objMetadataMachineReadableCodeObject = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        if objMetadataMachineReadableCodeObject.type == AVMetadataObjectTypeQRCode {
            let barCodeObject = captureVideoPreviewLayer!.transformedMetadataObjectForMetadataObject(objMetadataMachineReadableCodeObject as AVMetadataMachineReadableCodeObject) as! AVMetadataMachineReadableCodeObject
            focusFrame?.frame = barCodeObject.bounds;
            if objMetadataMachineReadableCodeObject.stringValue != nil {
                self.parseQRCodeContext(context: objMetadataMachineReadableCodeObject.stringValue)
            }
        }
    }
    
    func parseQRCodeContext(context context: String) {
        let url: NSURLComponents = NSURLComponents(string: context)!
        var config: Dictionary = [String: String]()
        
        if url.scheme == "shadowvpn" && url.host == "QRCode" {
            if captureSession != nil {
                captureSession?.stopRunning()
            }
            for item in url.queryItems! {
                config[item.name] = item.value
            }
            
            self.navigationController?.popViewControllerAnimated(true)
            self.delegate?.writeBack(configuration: config)
            
            // self.dismissViewControllerAnimated(true) { () -> Void in
            //     self.delegate?.writeBack(configuration: config)
            // }
        } else {
            NSLog(" Invalid QRCode Context: %@", context)
        }
        
    }
    
}
