//
//  ConfigurationValidator.swift
//  ShadowVPN
//
//  Created by clowwindy on 8/10/15.
//  Copyright © 2015 clowwindy. All rights reserved.
//

import UIKit

class ConfigurationValidator: NSObject {
    
    // return nil if there's no error
    class func validate(configuration: [String: AnyObject]) -> String? {
        // 1. server must be not empty
        if configuration["server"] == nil || configuration["server"]?.length == 0 {
            return "Server must not be empty"
        }
        // 2. port must be int 1, 65535
        if configuration["port"] == nil || configuration["port"]?.length == 0 {
            return "Port must not be empty"
        }
        let port = Int(configuration["port"] as! String)
        if port < 1 || port > 65535 {
            return "Port is invalid"
        }
        // 3. password must be not empty
        if configuration["password"] == nil || configuration["password"]?.length == 0 {
            return "Password must not be empty"
        }
        // 4. usertoken must be empty or hex of 8 bytes
        if configuration["usertoken"] != nil {
            if let usertoken = configuration["usertoken"] as? String {
                if NSData.fromHexString(usertoken).length != 8 {
                    return "Usertoken must be HEX of 8 bytes (string length: 16)"
                }
            }
        }
        // 5. ip must be valid IP
        // 6. subnet must be valid subnet
        // 7. dns must be comma separated ip addresses
        // 8. mtu must be int
        if configuration["mtu"] == nil || configuration["mtu"]?.length == 0 {
            return "MTU must not be empty"
        }
        let mtu = Int(configuration["mtu"] as! String)
        if mtu < 100 || mtu > 9000 {
            return "MTU is invalid"
        }
        // 9. routes must be empty or chnroutes
        return nil
    }
}
