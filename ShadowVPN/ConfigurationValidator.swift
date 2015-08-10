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
    class func validateIP(ip: String) -> String? {
        let parts = ip.componentsSeparatedByString(".")
        if parts.count != 4 {
            return "Invalid IP: " + ip
        }
        for part in parts {
            let n = Int(part)
            if n == nil || n < 0 || n > 255 {
                return "Invalid IP: " + ip
            }
        }
        return nil
    }
    
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
                if NSData.fromHexString(usertoken).length != 8 && NSData.fromHexString(usertoken).length != 0 {
                    return "Usertoken must be HEX of 8 bytes (example: 7e335d67f1dc2c01)"
                }
            }
        }
        // 5. ip must be valid IP
        if configuration["ip"] == nil || configuration["ip"]?.length == 0 {
            return "IP must not be empty"
        }
        if let ip = configuration["ip"] as? String {
            let r = validateIP(ip)
            if r != nil {
                return r
            }
        }
        // 6. subnet must be valid subnet
        if configuration["subnet"] == nil || configuration["subnet"]?.length == 0 {
            return "Subnet must not be empty"
        }
        if let subnet = configuration["subnet"] as? String {
            let r = validateIP(subnet)
            if r != nil {
                return r
            }
        }
        // 7. dns must be comma separated ip addresses
        if configuration["dns"] == nil || configuration["dns"]?.length == 0 {
            return "DNS must not be empty"
        }
        if let dns = configuration["dns"] as? String {
            let ips = dns.componentsSeparatedByString(",")
            if ips.count == 0 {
                return "DNS must not be empty"
            }
            for ip in ips {
                let r = validateIP(ip)
                if r != nil {
                    return r
                }
            }
        }
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
