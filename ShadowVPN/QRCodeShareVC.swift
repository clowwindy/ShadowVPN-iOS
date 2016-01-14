//
//  QRCodeShareVC.swift
//  ShadowVPN
//
//  Created by Joe on 16/2/11.
//  Copyright © 2016年 clowwindy. All rights reserved.
//

import UIKit

class QRCodeShareVC: UIViewController {
    var configQuery: String?

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
        let query: String = self.configQuery!
        
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setValue(query.dataUsingEncoding(NSUTF8StringEncoding), forKey: "inputMessage")
        
        let width: CGFloat = 200
        let heigth: CGFloat = 200
        let x = (self.view.bounds.width - width) / 2
        let y = (self.view.bounds.height - heigth) / 2
        
        let imgView: UIImageView = UIImageView(frame: CGRectMake(x, y, width, heigth))
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
        
        imgView.image = resultImage
        self.view.addSubview(imgView)
    }

}
