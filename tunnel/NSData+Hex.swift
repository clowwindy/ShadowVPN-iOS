//
//  NSData+Hex.swift
//  ShadowVPN
//
//  Created by clowwindy on 8/9/15.
//  Copyright © 2015 clowwindy. All rights reserved.
//

import Foundation

extension NSData {
    public class func fromHexString (string: String) -> NSData {
        let data = NSMutableData()
        var temp = ""
        
        for char in string.characters {
            temp += String(char)
            if temp.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == 2 {
                let scanner = NSScanner(string: temp)
                var value: CUnsignedInt = 0
                scanner.scanHexInt(&value)
                data.appendBytes(&value, length: 1)
                temp = ""
            }
            
        }
        
        return data as NSData
    }
}