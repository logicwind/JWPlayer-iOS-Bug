//
//  AppDelegate.swift
//  Casting
//
//  Created by David Almaguer on 9/3/19.
//  Copyright © 2019 Karim Mourra. All rights reserved.
//

import UIKit
import GoogleCast

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        GCKLogger.sharedInstance().delegate = self
        return true
    }


}

extension AppDelegate: GCKLoggerDelegate {
    
    func logMessage(_ message: String, at level: GCKLoggerLevel, fromFunction function: String, location: String) {
        print("Message from Chromecast = \(message)")
    }
}

