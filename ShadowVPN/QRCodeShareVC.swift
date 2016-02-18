//
//  QRCodeShareVC.swift
//  ShadowVPN
//
//  Created by Joe on 16/2/11.
//  Copyright © 2016年 clowwindy. All rights reserved.
//

import UIKit
import Photos

class QRCodeShareVC: UIViewController {
    var configQuery: String?
    var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: "save")
        self.title = "Share Configuration"
        
        self.displayQRCodeImage()
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
    
    func displayQRCodeImage() {
        // show Image
        let query: String = self.configQuery!
        
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setValue(query.dataUsingEncoding(NSUTF8StringEncoding), forKey: "inputMessage")
        
        let width: CGFloat = 200
        let heigth: CGFloat = 200
        let x = (self.view.bounds.width - width) / 2
        let y = (self.view.bounds.height - heigth) / 2
        
        self.imageView = UIImageView(frame: CGRectMake(x, y, width, heigth))
        let codeImage = UIImage(CIImage: (filter?.outputImage)!.imageByApplyingTransform(CGAffineTransformMakeScale(10, 10)))
        
        let iconImage = UIImage(named: "qrcode_avatar")
        
        let rect = CGRectMake(0, 0, codeImage.size.width, codeImage.size.height)
        UIGraphicsBeginImageContext(rect.size)
        
        codeImage.drawInRect(rect)
        let avatarSize = CGSizeMake(rect.size.width * 0.25, rect.size.height * 0.25)
        let avatar_x = (rect.width - avatarSize.width) * 0.5
        let avatar_y = (rect.height - avatarSize.height) * 0.5
        iconImage!.drawInRect(CGRectMake(avatar_x, avatar_y, avatarSize.width, avatarSize.height))
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        // let tapGR = UITapGestureRecognizer(target: self, action: "tapImage:")
        // imageView.userInteractionEnabled = true
        // imageView.addGestureRecognizer(tapGR)
        
        self.imageView.image = resultImage
        self.view.addSubview(self.imageView)
    }
    
    // func tapImage(sender: UITapGestureRecognizer) {
    //     print("image view tapped")
    // }
    
    func save() {
        // save code image to album
        
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
            UIImageWriteToSavedPhotosAlbum(self.imageView.image!, self, "image:didFinishSavingWithError:contextInfo:", nil)
        }

    }
    
    func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject) {
        if (error != nil) {
            NSLog("%@", error!)
        } else {
            let alert = UIAlertController(title: "Saved", message: "Image save to Photos", preferredStyle: UIAlertControllerStyle.Alert)
            let done = UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction) -> Void in
                self.navigationController?.popToRootViewControllerAnimated(true)
            })
            alert.addAction(done)
            self.presentViewController(alert, animated: true, completion: nil)
            NSLog("saved image to album")
        }
    }

}
