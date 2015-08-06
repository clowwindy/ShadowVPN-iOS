//
//  VPNConfiguration.swift
//  ShadowVPN
//
//  Created by clowwindy on 8/6/15.
//  Copyright © 2015 clowwindy. All rights reserved.
//

import UIKit

class VPNConfiguration: NSObject {
    var serverDescription: String?
    var server: String?
    var password: String?
    var net: String = "10.7.0.1/31"
    var mtu: Int = 1462
    var concurrency: Int = 1
    var dns: String = "8.8.8.8"
}
