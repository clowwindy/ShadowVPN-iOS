//
//  RouteManager.swift
//  ShadowVPN
//
//  Created by clowwindy on 8/9/15.
//  Copyright © 2015 clowwindy. All rights reserved.
//

import UIKit
import NetworkExtension

class RouteManager: NSObject {
    var cidrToSubnetMask = [
        "32": "255.255.255.255",
        "31": "255.255.255.254",
        "30": "255.255.255.252",
        "29": "255.255.255.248",
        "28": "255.255.255.240",
        "27": "255.255.255.224",
        "26": "255.255.255.192",
        "25": "255.255.255.128",
        "24": "255.255.255.0",
        "23": "255.255.254.0",
        "22": "255.255.252.0",
        "21": "255.255.248.0",
        "20": "255.255.240.0",
        "19": "255.255.224.0",
        "18": "255.255.192.0",
        "17": "255.255.128.0",
        "16": "255.255.0.0",
        "15": "255.254.0.0",
        "14": "255.252.0.0",
        "13": "255.248.0.0",
        "12": "255.240.0.0",
        "11": "255.224.0.0",
        "10": "255.192.0.0",
        "9": "255.128.0.0",
        "8": "255.0.0.0",
        "7": "254.0.0.0",
        "6": "252.0.0.0",
        "5": "248.0.0.0",
        "4": "240.0.0.0",
        "3": "224.0.0.0",
        "2": "192.0.0.0",
        "1": "128.0.0.0",
        "0": "0.0.0.0"
    ]
    init(route: String?, IPv4Settings: NEIPv4Settings) {
        super.init()
        if route == "chnroutes" {
            parseCHNRoutes(IPv4Settings)
        } else {
            NSLog("using default route")
            // TODO also support https://github.com/ashi009/bestroutetb
            IPv4Settings.includedRoutes = [NEIPv4Route.defaultRoute()]
        }
    }
    
    func parseCHNRoutes(IPv4Settings: NEIPv4Settings) {
        NSLog("parsing chnroutes")
        var routes = [NEIPv4Route]()
        let chnroutesPath = NSBundle.mainBundle().pathForResource("chnroutes", ofType: "txt")
        do {
            let content = try String(contentsOfFile: chnroutesPath!)
            let lines = content.componentsSeparatedByString("\n")
            for line in lines {
                let parts = line.componentsSeparatedByString("/")
                if parts.count == 2 {
                    let address = parts[0]
                    let subnet = self.cidrToSubnetMask[parts[1]]
                    // NSLog("adding route %@", address)
                    routes.append(NEIPv4Route(destinationAddress: address, subnetMask: subnet!))
                }
            }
        } catch {
            NSLog("$@", String(error))
        }
        IPv4Settings.includedRoutes = [NEIPv4Route.defaultRoute()]
        IPv4Settings.excludedRoutes = routes
    }
}
