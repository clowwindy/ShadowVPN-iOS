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
    init(route: String?, IPv4Settings: NEIPv4Settings) {
        IPv4Settings.includedRoutes = [NEIPv4Route.defaultRoute()]
    }
}
