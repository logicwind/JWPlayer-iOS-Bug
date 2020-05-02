//
//  AppDelegate.swift
//  Voicer
//
//  Created by Karim Mourra on 9/21/16.
//  Copyright © 2016 Karim Mourra. All rights reserved.
//

import UIKit
import Intents
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.enableBackgroundAudio()
        return true
    }
    
    func enableBackgroundAudio() -> Void {
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(.playback)
        do {
            try audioSession.setCategory(.playback)
        } catch {
            print("failure")
        }
        try? audioSession.setActive(true)
        do {
            try audioSession.setActive(true)
        } catch {
            print("failure")
        }
    }
    
    // Calling the block restorationHandler is optional and is only needed when specific objects are capable of continuing the activity.
    // See more: https://developer.apple.com/documentation/uikit/uiapplicationdelegate/1623072-application
    private func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        let navigationController = application.keyWindow?.rootViewController as! UINavigationController
        let currentVoicerViewController = navigationController.children[0] as? VoicerViewController
        let userIntent = userActivity.interaction?.intent
        currentVoicerViewController?.handle(intent: userIntent!)
        return true
    }
}

